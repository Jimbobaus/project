# --- packages
library(data.table)
library(dplyr)
library(forecast)
library(lubridate)
library(psych)

# --- directories
input_loc= "~/input/"
output_loc = "~/output/"
train_y_name="ytrain.csv"
test_y_name="ytest.csv"
train_y_loc=paste(input_loc,train_y_name,sep="")
test_y_loc=paste(input_loc,test_y_name,sep="")

# --- import data
train_y = setDT(read.csv(train_y_loc, header=T))
test_y = setDT(read.csv(test_y_loc, header=T))
all = setDT(rbind(train_y,test_y))[order(DATETIME)] %>% mutate(DATETIME=ymd_hms(DATETIME))
all_y = data.frame(all$TOTALDEMAND)
train_y = subset(all_y, end=0.8*length(all_y))   # first 80%
test_y= subset(all_y, start=0.8*length(all_y)+1) # last 20%

# --- convert to time series format
findfrequency(train_y) # 48 (number of 30min intervals in a day)
train_y_ts =ts(train_y, frequency = 48)

# --- summary stats of training data
(train_y_ts_summary=describe(train_y_ts))
# vars      n    mean      sd  median trimmed     mad     min      max   range skew kurtosis   se
# X1    1 161185 7970.52 1240.24 7925.72 7914.81 1246.72 5074.63 13985.87 8911.24 0.47     0.21 3.09

# --- model
(model_arima = auto.arima(train_y_ts, seasonal = F)) # arima(3,1,2)
# Series: train_y_ts 
# ARIMA(3,1,2) 
# 
# Coefficients:
#   ar1     ar2      ar3      ma1      ma2
# 1.3357  0.0311  -0.4233  -0.5668  -0.4143
# s.e.  0.0127  0.0229   0.0107   0.0129   0.0128
# 
# sigma^2 estimated as 12944:  log likelihood=-991782.5
# AIC=1983577   AICc=1983577   BIC=1983637

# --- accuracy
test_y_ts =ts(test_y, frequency = 48)
model_results <- Arima(test_y_ts, model=model_arima)
accuracy(model_results) # 113.7675 RMSE
# ME     RMSE      MAE         MPE   MAPE      MASE       ACF1
# Training set 0.006098198 113.7675 83.90262 -0.01790531 1.042687 0.1888699 0.02374432




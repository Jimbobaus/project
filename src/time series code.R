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
train_y = head(all_y, 0.8*nrow(all_y))   # first 80%
test_y= tail(all_y, 0.2*nrow(all_y)) # last 20%
sum(all$TOTALDEMAND) == sum(train_y) + sum(test_y) # TRUE

# --- convert to time series format
findfrequency(train_y) # 48 (number of 30min intervals in a day)
train_y_ts =ts(train_y, frequency = 48)

# --- summary stats of training data
(train_y_ts_summary=describe(train_y_ts))
# vars      n    mean      sd  median trimmed     mad     min      max   range skew kurtosis   se
# X1    1 128948 8024.58 1239.18 8011.53 7978.95 1243.71 5074.63 13985.87 8911.24  0.4     0.19 3.45

# --- model
(model_arima = auto.arima(train_y_ts, seasonal = F)) # arima(4,1,2)
# Series: train_y_ts 
# ARIMA(4,1,2) 
# 
# Coefficients:
#   ar1     ar2      ar3      ar4      ma1      ma2
# 0.8243  0.8931  -0.7242  -0.0681  -0.0446  -0.9328
# s.e.  0.0040  0.0060   0.0042   0.0029   0.0029   0.0029
# 
# sigma^2 estimated as 13143:  log likelihood=-794412.1
# AIC=1588838   AICc=1588838   BIC=1588907

# --- accuracy
test_y_ts =ts(test_y, frequency = 48)
model_results <- Arima(test_y_ts, model=model_arima)
accuracy(model_results) # 110.615 RMSE
# ME    RMSE     MAE          MPE     MAPE      MASE       ACF1
# Training set -0.1000962 110.615 82.1002 -0.009748878 1.039758 0.1801267 0.05788134




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
findfrequency(train_y) # frequency of 48 (number of 30min intervals in a day)
train_y_ts =ts(train_y, frequency = 48)

# --- summary stats of training data
(train_y_ts_summary=describe(train_y_ts))

# --- model
(model_arima = auto.arima(train_y_ts, seasonal = F)) # arima(3,1,2)
# Series: train_y_ts 
# ARIMA(3,1,2) 
# 
# Coefficients:
#   ar1     ar2      ar3      ma1      ma2
# 1.3414  0.0205  -0.4169  -0.5756  -0.4069
# s.e.  0.0135  0.0243   0.0114   0.0138   0.0137
# 
# sigma^2 estimated as 13017:  log likelihood=-884104.6
# AIC=1768221   AICc=1768221   BIC=1768280

# --- accuracy
test_y_ts =ts(test_y, frequency = 48)
model_results <- Arima(test_y_ts, model=model_arima)
accuracy(model_results) # 111.1632 RMSE
# ME     RMSE      MAE         MPE   MAPE      MASE       ACF1
# Training set -0.05357386 111.1632 82.49621 -0.01114305 1.0509 0.1793849 0.07106744




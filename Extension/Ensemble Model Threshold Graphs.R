#Adapted from the caret vignette
library("caret")
library("mlbench")
library("pROC")
library("caretEnsemble")

#The training and testing datasets are read into R and then prepared for the model building phase.

test.raw.class <- read.csv("C:/Users/Mark/Documents/creditcard/test_data_Class.csv",stringsAsFactors = FALSE)

train.raw <- read.csv("C:/Users/Mark/Documents/creditcard/train.csv",stringsAsFactors = FALSE)

train_id <- train.raw$id

#train.raw$Class <- as.factor(train.raw$Class)

train.raw$Class <- as.factor(ifelse(train.raw$Class == 0,'Good', 'Bad'))

test.raw <- read.csv("C:/Users/Mark/Documents/creditcard/test_NoClass.csv",stringsAsFactors = FALSE)

test_id <- test.raw$id

train.raw <- train.raw[,-1]

test.raw <- test.raw[,-1]

train.raw <- train.raw[,-1]

test.raw <- test.raw[,-1]

test.raw$Time<- as.numeric(test.raw$Time)

train.raw$Time<- as.numeric(train.raw$Time)

train.raw$Time <- scale(train.raw$Time)

test.raw$Time <- scale(test.raw$Time)

train.raw$Amount <- scale(train.raw$Amount)

test.raw$Amount <- scale(test.raw$Amount)

'================================================================================================================='

#Reading an XGB model into R to make predictions.

xgb_mdl <- readRDS("C:/Users/Mark/Documents/creditcard/xgb_subset_ensemble.rds")

xgb_mdl_yhat <- predict(xgb_mdl,newdata = train.raw[,-31],type = "prob")

n <- 100

df <- data.frame()

for (i in c(1:99)) {
  
  metrics <- confusionMatrix(as.factor(ifelse(predict(xgb_mdl,newdata = test.raw,type = "prob") > i/n,'1','0')), as.factor(test.raw.class$Class), mode = "prec_recall",positive = "1")
  
  #Storing metrics as a dataframe 
  
  df[i,1] <- i/n
  df[i,2] <- metrics$byClass[5]
  df[i,3] <- metrics$byClass[6]
  df[i,4] <- metrics$byClass[7]
  
  #confusionMatrix(as.factor(ifelse(predict(xgb_mdl,newdata = test.raw,type = "prob")$Bad > 0.5,'1','0')), as.factor(test.raw.class$Class), mode = "prec_recall",positive = "1")
  
}

colnames(df) <- c("Threshold","Precision", "Recall", "F1 Score")

library(ggplot2)
library(reshape2)

df <- melt(df, id.vars="Threshold")

df_new <- df

colnames(df_new) <- c("Threshold","Performance Metric","Value")

# Everything on the same plot
ggplot(df_new, aes(Threshold,Value, col=`Performance Metric`)) + 
  geom_line() + xlab("Threshold") + ylab("Value") + ggtitle("Plot of the Performance Metrics against Threshold") + 
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5))


#Timing the entire procedure to compare with earlier classifiers.

start.time <- Sys.time()

#Adapted from the caret vignette
library("caret")
library("mlbench")
library("pROC")

library(doMC)
library(parallelMap)
library(parallel)

registerDoMC(cores = detectCores())

#The training and testing datasets are read into R and then prepared for the model building phase.

test.raw.class <- read.csv("C:/Users/Mark/Documents/creditcard/test_data_Class.csv",stringsAsFactors = FALSE)

train.raw <- read.csv("C:/Users/Mark/Documents/creditcard/train_subset.csv",stringsAsFactors = FALSE)

#train_id <- train.raw$id

#train.raw$Class <- as.factor(train.raw$Class)

train.raw$Class <- as.factor(ifelse(train.raw$Class == 0,'Good', 'Bad'))

test.raw <- read.csv("C:/Users/Mark/Documents/creditcard/test_NoClass.csv",stringsAsFactors = FALSE)

test_id <- test.raw$id

train.raw <- train.raw[,-1]

test.raw <- test.raw[,-1]

#train.raw <- train.raw[,-1]

test.raw <- test.raw[,-1]

test.raw$Time<- as.numeric(test.raw$Time)

train.raw$Time<- as.numeric(train.raw$Time)

train.raw$Time <- scale(train.raw$Time)

test.raw$Time <- scale(test.raw$Time)

train.raw$Amount <- scale(train.raw$Amount)

test.raw$Amount <- scale(test.raw$Amount)

'================================================================================================================='

#Cross-Validated training data 5 times. 

my_control <- trainControl(method="repeatedcv",
                           number=5,
                           repeats=1,
                           verboseIter=TRUE,
                           summaryFunction = twoClassSummary,
                           classProbs = TRUE,
                           allowParallel = TRUE)

#Functions for creating ensembles of caret models.

library("caretEnsemble")

model_list <- caretList(
  Class~., data=train.raw,
  trControl=my_control,
  methodList=c("ranger", "xgbTree", "gbm")
)

modelCor(resamples(model_list))

greedy_ensemble <- caretEnsemble(
  model_list, 
  metric="ROC",
  trControl=trainControl(
    number=5,
    summaryFunction=twoClassSummary,
    classProbs=TRUE,
    allowParallel = TRUE,
    verboseIter=TRUE
  ))

summary(greedy_ensemble)

library(caret)

confusionMatrix(as.factor(ifelse(predict(greedy_ensemble, newdata = train.raw[,-31], type = "prob") > 0.5,'Bad','Good')),  train.raw$Class, mode = "prec_recall",positive = "Bad")

confusionMatrix(as.factor(ifelse(predict(greedy_ensemble,newdata = test.raw, type = "prob") > 0.5,'1','0')), as.factor(test.raw.class$Class), mode = "prec_recall",positive = "1")

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

saveRDS(greedy_ensemble, "C:/Users/Mark/Documents/creditcard/greedy_ensemble.rds")

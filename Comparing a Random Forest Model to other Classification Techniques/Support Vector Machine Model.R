#The training and testing datasets are read into R and then prepared for the model building phase.

library(rpart)
library(kernlab)

train_data <- read.csv('C:/Users/Mark/Documents/creditcard/train.csv')

test_data <- read.csv('C:/Users/Mark/Documents/creditcard/test_NoClass.csv')

test_data_Class <- read.csv('C:/Users/Mark/Documents/creditcard/test_data_Class.csv')

train_data <- train_data[,-1]

test_data <- test_data[,-1]

test_data_Class <- test_data_Class[,-1]

train_data_Class <- train_data[,32]

str(train_data)

colnames(train_data)

colnames(test_data)

colnames(test_data_Class)

train_data <- train_data[,-1]

test_data <- test_data[,-1]

test_data_Class <- test_data_Class[,-1]

'========================================================================================================='

#Timing the model building phase.

start.time <- Sys.time()

SVM_model <- ksvm(as.factor(Class) ~ .,
                 data=train_data,
                 kernel="rbfdot",
                 prob.model=TRUE)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

#Making Predictions on the test and train data

train_pred <- predict(SVM_model, train_data)

test_pred <- predict(SVM_model, test_data)

'========================================================================================================='

table(test_data_Class)

library(caret)

#Obtaining F1, recall and precision scores for the model 

confusionMatrix(train_pred, train_data_Class, mode = "prec_recall",positive = "1")

confusionMatrix(test_pred, test_data_Class, mode = "prec_recall",positive = "1")


# Runs 2 models: The fixed effects logistic regression and the mixed effects model

options(warn=-1)

library(lme4)
library(ROCR)
library(data.table)

train_file_path <- "/home/fatigue_internship/output_statistics/all_data/training_data.csv"
test_file_path <- "/home/fatigue_internship/output_statistics/all_data/test_data.csv" 

DT_train <- fread(train_file_path)
DT_test <- fread(test_file_path)

DT_random_train <- DT_train[sample(nrow(DT_train), 100000), ]
DT_random_test <- DT_test[sample(nrow(DT_test), 100000), ]

# DT_random <- DT


# print(head(DT_random))
# print(nrow(DT_random))



DT_random_train[, CAMPAIGNCODE := as.factor(CAMPAIGNCODE)]
DT_random_train[, RECIPIENTID := as.factor(RECIPIENTID)]
DT_random_train[, OPENED := as.numeric(OPENED)]


DT_random_test[, CAMPAIGNCODE := as.factor(CAMPAIGNCODE)]
DT_random_test[, RECIPIENTID := as.factor(RECIPIENTID)]
DT_random_test[, OPENED := as.numeric(OPENED)]


rids <- unique(DT_random_train$RECIPIENTID)
DT_test_ <- DT_random_test[RECIPIENTID %in% rids]


# Fixed Effects model
m1 <- glm(formula=OPENED~1 + COUNTSENT + COUNTOPENED + COUNTCLICKED + COUNTUNSUBSCRIBED + COUNTCOMPLAINS + COUNTORDERS + COUNTORDERVALUE, data=DT_random_train, family=binomial(link="logit"))

predict_m1 <- predict(m1, DT_test_, type='response')
pr <- prediction(predict_m1, DT_test_$OPENED)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc


predict_m1 <- ifelse(predict_m1 > 0.5, 1, 0)
misClasificError_fe <- mean(predict_m1 != DT_test_$OPENED)
print(paste('Accuracy of fixed effects: ',1-misClasificError_fe))






# Random Effects model
m2 <- glmer(formula=OPENED~COUNTSENT + COUNTOPENED + COUNTCLICKED + COUNTUNSUBSCRIBED + COUNTCOMPLAINS + COUNTORDERS + COUNTORDERVALUE + (1|RECIPIENTID), data=DT_random_train, family=binomial, verbose=2, control = glmerControl(optimizer = "bobyqa"))

predict_m2 <- predict(m2, DT_test_, type='response')
pr2 <- prediction(predict_m2, DT_test_$OPENED)
prf2 <- performance(pr2, measure = "tpr", x.measure = "fpr")
plot(prf2)

auc <- performance(pr2, measure = "auc")
auc <- auc@y.values[[1]]
auc


predict_m2 <- ifelse(predict_m2 > 0.5, 1, 0)

misClasificError_re <- mean(predict_m2 != DT_test_$OPENED)
print(paste('Accuracy',1-misClasificError_re))







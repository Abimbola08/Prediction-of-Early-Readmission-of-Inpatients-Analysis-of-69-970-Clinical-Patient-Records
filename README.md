# Prediction-of-Early-Readmission-of-Inpatients-Analysis-of-69-970-Clinical-Patient-Records

---
title: "Final Project"
author: "Abimbola Ogungbire"
date: "22/04/2020"
output:
  html_document:
    df_print: paged
  word_document: default
---

```{r Libraries, include =FALSE}

library(knitr)
library(dplyr)
library(tidyverse)
library(kableExtra)
library(DT)
library(summarytools)
library(car)

```

## Import the Data
In recreating Table 3 in the paper, I have imported all 69, 973 datasets from the last Assignment. Below is the structure of the data set

```{r, include=FALSE, echo=FALSE}
df <- read.csv("diabetic_data.csv")


```
```{r}
df <- replace(df, df == '?', NA)
df1 = df %>% 
  select(-weight, -payer_code) %>%
  distinct(patient_nbr, .keep_all = TRUE) %>%
  filter(discharge_disposition_id != 11) %>%
  filter(discharge_disposition_id != 13) %>%
  filter(discharge_disposition_id != 14) %>%
  filter(discharge_disposition_id != 19) %>%
  filter(discharge_disposition_id != 20) %>%
  filter(discharge_disposition_id != 21)

```
## Grouping Primary Diagnosis

I have followed the guide in Table 2 in order to group the primary diagnosis as follows, I have attached a table to count distinct primary diagnosis in the variariable "diag_1" at the end of this report. The code used in grouping is as presented below.

```{r, include=TRUE, echo=TRUE}
split1 <- df1 %>%
  filter(diag_1=="E909" | diag_1=="V25" | diag_1=="V26" | diag_1=="V43"| diag_1=="V45" | diag_1=="V51" | diag_1=="V53" | diag_1=="V54"| diag_1=="V55" | diag_1=="V56" | diag_1=="V57" | diag_1=="V58" | diag_1=="V60" | diag_1=="V63" | diag_1=="V66" | diag_1=="V67"| diag_1=="V70" | diag_1=="V71")
split1$diag_1 <- ifelse(split1$diag_1 != "NA", "Other", "")
split1$diag_1 <- as.character(split1$diag_1)
df1$diag_1 <- as.character(df1$diag_1)

split2 <- setdiff(df1 , split1)

split2$diag_1 <- as.character(split2$diag_1)
split2$diag_1 <- as.numeric(split2$diag_1)

split2$diag_1 <-ifelse(split2$diag_1 >= 390 & split2$diag_1 <= 459 | split2$diag_1 == 785  , "Cirulatory",
                       ifelse(split2$diag_1 >= 460 & split2$diag_1 <= 519 | split2$diag_1 == 786  , "Respiratory",
                              ifelse(split2$diag_1 >= 520 & split2$diag_1 <= 579 | split2$diag_1 == 787  , "Digestive",        
                                     ifelse(split2$diag_1 >= 250 & split2$diag_1 <= 250.99, "Diabetes",
                                            ifelse(split2$diag_1 >= 800 & split2$diag_1 <= 999 , "Injury",
                                                   ifelse(split2$diag_1 >= 710 & split2$diag_1 <= 739, "Musculoskeletal",
                                                          ifelse(split2$diag_1 >= 580 & split2$diag_1 <= 629 |split2$diag_1 == 788, "Genitourinary",
                                                                 ifelse(split2$diag_1 >= 140 & split2$diag_1 <= 239 , "Neoplasms",
                                                                        ifelse(split2$diag_1 == 780 |split2$diag_1 == 781|split2$diag_1 == 784 |split2$diag_1 == 789
                                                                               |split2$diag_1 >= 790 & split2$diag_1<=799 |split2$diag_1 >= 240 &
                                                                                 split2$diag_1 < 250 |split2$diag_1 >= 251 & split2$diag_1 <= 279 |
                                                                                 split2$diag_1 >= 680 & split2$diag_1 <= 709 | split2$diag_1 == 782|
                                                                                 split2$diag_1 >= 1   & split2$diag_1 <= 139 |
                                                                                 split2$diag_1 >= 290 & split2$diag_1 <= 319|
                                                                                 split2$diag_1 >= 280 & split2$diag_1 <= 289|
                                                                                 split2$diag_1 >= 320 & split2$diag_1 <= 359|
                                                                                 split2$diag_1 >= 630 & split2$diag_1 <= 679|
                                                                                 split2$diag_1 >= 360 & split2$diag_1 <= 389|
                                                                                 split2$diag_1 >= 740 & split2$diag_1 <= 759  ,"Other","Unknown"
                                                                        ) ) ) ) ) ) ) ) )


split2$diag_1 <- as.factor(split2$diag_1)
split1$diag_1 <- as.factor(split1$diag_1)

new_df <- split2

ggplot(new_df, aes(x = diag_1)) +
  geom_bar(aes(fill = diag_1)) + 
  theme(axis.text.x = element_text(angle = 45))






```


## Grouping Discharge Disposition

Discharge disposition has been grouped into inpatients who are discharges to home or others. Below is the code used to achieve this.

```{r, include =TRUE}

new_df$discharge_disposition_id <- ifelse(new_df$discharge_disposition_id == 1 | new_df$discharge_disposition_id == 8 , "Discharged to home", "Others")
new_df$discharge_disposition_id <- as.character(new_df$discharge_disposition_id)

ggplot(new_df, aes(x = discharge_disposition_id)) +
  geom_bar(aes(fill = discharge_disposition_id)) + 
  theme(axis.text.x = element_text(angle = 45))




```


## Age Grouping

The variable “Age” has been consolidated from a factor of ten levels and encoded as 1, 1.5 and 2 i.e. ages less than 30, between 30-60 and older than 60 respectively. The idea is that older people are twice more likely to be admitted than the younger ones.

```{r, include =TRUE}

new_df$age <- ifelse(new_df$age == "[0-10)", 5,
                     ifelse(new_df$age == "[10-20)", 15,
                            ifelse(new_df$age == "[20-30)", 25,
                                   ifelse(new_df$age == "[30-40)", 35,
                                          ifelse(new_df$age == "[40-50)", 45,
                                                 ifelse(new_df$age == "[50-60)", 55,
                                                        ifelse(new_df$age == "[60-70)", 65,
                                                               ifelse(new_df$age == "[70-80)", 75,
                                                                      ifelse(new_df$age == "[80-90)", 85, 95
                            )))))))))

ggplot(new_df, aes(x = age)) +
  geom_bar(aes(fill = age)) + 
  theme(axis.text.x = element_text(angle = 45))

summary(new_df$age)


```


## Gender Grouping

Cases with an unknown gender type are very few in number and so I have resorted to getting rid of them. The below chat represent the number of male and females in the data set.

```{r, include =TRUE}
# Gender
new_df <- new_df%>%
  filter(gender=="Male"|gender=="Female")

ggplot(new_df, aes(x = gender)) +
  geom_bar(aes(fill = gender)) + 
  theme(axis.text.x = element_text(angle = 45))


```

## Race Grouping

There are categories in the race variable that are not considered as race, these categories (Hispanic and Asian) have been regrouped into the Other category. Below is a chart showing the proportion of ezch caegory in the variable.

```{r, include =TRUE}

new_df$race <- ifelse(new_df$race == "AfricanAmerican", "AfricanAmerican",
                      ifelse(new_df$race == "Caucasian", "Caucasian",
                             ifelse(new_df$race == "Other", "Other", "Missing"
                                    
                     )))
new_df$race = replace_na(data = new_df$race, replace = 'Missing')


ggplot(new_df, aes(x = race)) +
  geom_bar(aes(fill = race)) + 
  theme(axis.text.x = element_text(angle = 45))




```

## Medical Specialty grouping

The Medical specialty has been grouped according to the chard shown below. A table of count is shown at the end of the report.


```{r, include = TRUE}
#Medical Specialty grouping
new_df$medical_specialty <- as.character(new_df$medical_specialty )
new_df$medical_specialty <- replace_na(data = new_df$medical_specialty, replace = 'Missing')

new_df$medical_specialty <- ifelse(new_df$medical_specialty == "SurgicalSpecialty" | new_df$medical_specialty == "Surgery-Vascular" | new_df$medical_specialty == "Surgery-Thoracic" | new_df$medical_specialty == "Surgery-PlasticwithinHeadandNeck" | new_df$medical_specialty == "Surgery-Plastic" | new_df$medical_specialty == "Surgery-Pediatric" | new_df$medical_specialty == "Surgery-Neuro" | new_df$medical_specialty == "Surgery-Maxillofacial" | new_df$medical_specialty == "Surgery-General" | new_df$medical_specialty == "Surgery-Colon&Rectal" | new_df$medical_specialty == "Surgery-Cardiovascular/Thoracic" | new_df$medical_specialty == "Surgery-Cardiovascular" | new_df$medical_specialty == "Surgeon", "Sugery", 
                                   ifelse(new_df$medical_specialty == "Cardiology" | new_df$medical_specialty == "Cardiology-Pediatric", "Cardiology",
                                          ifelse(new_df$medical_specialty == "InternalMedicine", "InternalMedicine",
                                                 ifelse(new_df$medical_specialty == "Family/GeneralPractice", "Family/GeneralPractice",
                                                        ifelse(new_df$medical_specialty == "Missing", "Missing", "Other"
                                                               )))))

ggplot(new_df, aes(x = medical_specialty)) +
  geom_bar(aes(fill = medical_specialty)) + 
  theme(axis.text.x = element_text(angle = 45))


```


## HbA1c grouping

The A1c result variable has been regrouped according to the chart below.

```{r, include =TRUE, echo=TRUE}
#HA1c grouping
new_df$A1Cresult <- ifelse(new_df$A1Cresult == ">8" & new_df$change == "Ch", "High Result & Med was changed",
                           ifelse(new_df$A1Cresult == ">8" & new_df$change == "No", "High Result & Med was not changed",
                                  ifelse(new_df$A1Cresult == "None", "None",
                                         ifelse(new_df$A1Cresult == "Norm", "Norm", "Norm"
                                         ))))

ggplot(new_df, aes(x = A1Cresult)) +
  geom_bar(aes(fill = A1Cresult)) + 
  theme(axis.text.x = element_text(angle = 45))



```


## Admission Source Grouping

The admission source has been regrouped into inpatients that were refered by either physician or clinic and those that were readmitted from the emergency room. the chart below show the value count of distint category in the variable.

```{r, include = TRUE,echo= TRUE}

new_df$admission_source_id <- ifelse(new_df$admission_source_id == 1 | new_df$admission_source_id == 2, "Physician/Clinal Referral",
                           ifelse(new_df$admission_source_id == 7, "Emmergency Room", "Otherwise"
                                         )) 

ggplot(new_df, aes(x = admission_source_id)) +
  geom_bar(aes(fill = admission_source_id)) + 
  theme(axis.text.x = element_text(angle = 45))




```

## Recoding readmitted

```{r, echo=TRUE}
new_df$readmitted <- ifelse(new_df$readmitted == "<30", "1","0")

new_df$readmitted <- as.factor(new_df$readmitted)
```



View(new-DF)
## Tables of variable counts.

Below are tables showing results of dintint value counts in each variables.

```{r, include =TRUE}


table(new_df$A1Cresult)
table(new_df$gender)
table(new_df$discharge_disposition_id)
table(new_df$admission_source_id)
table(new_df$medical_specialty)
table(new_df$diag_1)
table(new_df$race)
table(new_df$age)



```

## Spliting the Data into Train and Test Data Set

```{r}
set.seed(123)
library(caTools)
split <- sample.split(new_df, SplitRatio = 0.7)
train <- subset(new_df, split == TRUE) # train data made up of 70% of original dataset
test <-  subset(new_df, split == FALSE)# test data made up of 30% of original dataset

```

## Fitting the Model

The model fitting has been carried out in four phases; first model has been fitted to include all other variables except HbA1c.The second model has been built on the train data to include A1c result as shown below.


** Adding HbA1c result.**

```{r, echo=TRUE}
fit <- glm(readmitted ~ discharge_disposition_id + race + admission_source_id + medical_specialty + time_in_hospital + age + diag_1 + A1Cresult, data = train, family = "binomial")
summary(fit)

```

## Using the above model on test data

```{r}
library(broom)
library(pROC)
fit_predict <- fit %>%
  augment(type.predict = "response", newdata = test)
```

```{r}
ROC_fit <- roc(test$readmitted, fit_predict$.fitted)
plot(ROC_fit)
auc(ROC_fit)

```

```{r}
final_fit <- glm(readmitted ~ A1Cresult + race + discharge_disposition_id + age + admission_source_id + time_in_hospital + diag_1 + medical_specialty + age:medical_specialty + discharge_disposition_id:diag_1 + race:discharge_disposition_id + time_in_hospital:discharge_disposition_id + discharge_disposition_id:medical_specialty + time_in_hospital:medical_specialty + age:medical_specialty + time_in_hospital:diag_1 + A1Cresult:diag_1, data = train, family = "binomial")
summary(final_fit)22

```

```{r}
final_fit_predict <- final_fit %>%
  augment(type.predict = "response", newdata = test)
```

```{r}
ROC_final_fit <- roc(test$readmitted, final_fit_predict$.fitted)
plot(ROC_final_fit)
auc(ROC_final_fit)

```

## Confusion Matrix

```{r}
library(broom)
confusion_matrix <- final_fit %>%
  augment(type.predict = "response", newdata = test) %>%
  mutate(predictive = ifelse(.fitted > 0.25, 1, 0))

table(confusion_matrix$readmitted, confusion_matrix$predictive)
```

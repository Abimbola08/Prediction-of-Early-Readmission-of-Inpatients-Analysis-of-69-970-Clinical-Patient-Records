library(dplyr)
library(tidyr)
library(ggplot2)
library(naniar)
library(BaylorEdPsych)
library(mvnmle)
library(reshape2)
library(leaps)
library(mice)


df <- read.csv("diabetic_data.csv")
View(df)
str(df)
df <- replace(df, df == '?', NA)

p <- function(x) {sum(is.na(x))/length(x)*100}
barplot(apply(df, 2, p), las = 0)
abline(h = 30, col="red")


df1 = df %>% 
  select(-weight, -payer_code) %>%
  distinct(patient_nbr, .keep_all = TRUE) %>%
  filter(discharge_disposition_id != 11) %>%
  filter(discharge_disposition_id != 13) %>%
  filter(discharge_disposition_id != 14) %>%
  filter(discharge_disposition_id != 19) %>%
  filter(discharge_disposition_id != 20) %>%
  filter(discharge_disposition_id != 21)

summary(df1)

summary(df1$diag_1)
split1 <- df1 %>%
  filter(diag_1=="E909" | diag_1=="V25" | diag_1=="V26" | diag_1=="V43"| diag_1=="V45" | diag_1=="V51" | diag_1=="V53" | diag_1=="V54"| diag_1=="V55" | diag_1=="V56" | diag_1=="V57" | diag_1=="V58" | diag_1=="V60" | diag_1=="V63" | diag_1=="V66" | diag_1=="V67"| diag_1=="V70" | diag_1=="V71")
split1$diag_1 <- ifelse(split1$diag_1 != "NA", "Other", "")
split1$diag_1 <- as.character(split1$diag_1)
df1$diag_1 <- as.character(df1$diag_1)

split2 <- setdiff(df1 , split1)
summary(split2$diag_1)


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
summary(split2$diag_1)

new_df <- rbind(split1, split2)

# disposition grouping
new_df$discharge_disposition_id <- ifelse(new_df$discharge_disposition_id == 1 | new_df$discharge_disposition_id == 8 , "Discharged to home", "Others")
new_df$discharge_disposition_id <- as.character(new_df$discharge_disposition_id)

# Age grouping
new_df$age <- ifelse(new_df$age == "[0-10)"|new_df$age == "[10-20)"|new_df$age == "[20-30)", "1",
                     ifelse(new_df$age == "[30-40)"|new_df$age == "[40-50)"|new_df$age == "[50-60)" , "1.5", "2"
                            ))

# Gender
new_df <- new_df%>%
  filter(gender=="Male"|gender=="Female")

ggplot(new_df, aes(x = diag_1, y = time_in_hospital)) +
  geom_boxplot(aes(fill = diag_1)) + 
  theme(axis.text.x = element_text(angle = 45))

ggplot(new_df, aes(x = readmitted, y = time_in_hospital)) +
  geom_bar(aes(fill = readmitted)) + 
  theme(axis.text.x = element_text(angle = 45))

new_df$race <- ifelse(new_df$race == "AfricanAmerican", "AfricanAmerican",
                      ifelse(new_df$race == "Caucasian", "Caucasian",
                             ifelse(new_df$race == "Other", "Other", "Missing"
                                    
                     )))
new_df$race = replace_na(data = new_df$race, replace = 'Missing')

new_df$medical_specialty <- as.character(new_df$medical_specialty )
new_df$medical_specialty <- replace_na(data = new_df$medical_specialty, replace = 'Missing')

new_df$medical_specialty <- ifelse(new_df$medical_specialty == "SurgicalSpecialty" | new_df$medical_specialty == "Surgery-Vascular" | new_df$medical_specialty == "Surgery-Thoracic" | new_df$medical_specialty == "Surgery-PlasticwithinHeadandNeck" | new_df$medical_specialty == "Surgery-Plastic" | new_df$medical_specialty == "Surgery-Pediatric" | new_df$medical_specialty == "Surgery-Neuro" | new_df$medical_specialty == "Surgery-Maxillofacial" | new_df$medical_specialty == "Surgery-General" | new_df$medical_specialty == "Surgery-Colon&Rectal" | new_df$medical_specialty == "Surgery-Cardiovascular/Thoracic" | new_df$medical_specialty == "Surgery-Cardiovascular" | new_df$medical_specialty == "Surgeon", "Sugery", 
                                   ifelse(new_df$medical_specialty == "Cardiology" | new_df$medical_specialty == "Cardiology-Pediatric", "Cardiology",
                                          ifelse(new_df$medical_specialty == "InternalMedicine", "InternalMedicine",
                                                 ifelse(new_df$medical_specialty == "Family/GeneralPractice", "Family/GeneralPractice",
                                                        ifelse(new_df$medical_specialty == "Missing", "Missing", "Other"
                                                               )))))
table(new_df$medical_specialty)


new_df$A1Cresult <- ifelse(new_df$A1Cresult == ">8" & new_df$change == "Ch", "High Result & Med was changed",
                           ifelse(new_df$A1Cresult == ">8" & new_df$change == "No", "High Result & Med was not changed",
                                  ifelse(new_df$A1Cresult == "None", "None",
                                         ifelse(new_df$A1Cresult == "Norm", "Norm", "Norm"
                                         ))))

new_df$admission_source_id <- ifelse(new_df$admission_source_id == 1 | new_df$admission_source_id == 2, "Physician/Clinal Referral",
                           ifelse(new_df$admission_source_id == 7, "Emmergency Room", "Otherwise"
                                         ))                             

table(new_df$A1Cresult)
table(new_df$gender)
table(new_df$discharge_disposition_id)
table(new_df$admission_source_id)
table(new_df$medical_specialty)
table(new_df$diag_1)
table(new_df$race)
table(new_df$age)

group_by(readmitted) %>%
  mutate(
    count_sum = sum(count),
    relevant_count_sum = if_else(sum == "Aquatic", total_count_sum, count_sum),
    percent = count/relevant_count_sum * 100)

ifelse()

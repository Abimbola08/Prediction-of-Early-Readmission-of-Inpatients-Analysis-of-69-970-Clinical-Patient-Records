library(dplyr)
data_training = read.table("final_training.csv", header=T, sep=",")
attach(data_training)

# Exploring the data
str(data_training)
summary(data_training)

# Cleaning and encoding the variable name 'Integer'
data_training$Date <- as.integer(Date)
data_training <- data_training %>%
  mutate(Date = ifelse(Date == 2012, 1, 0))
detach(data_training)

attach(data_training)
# Visualize the data on a pairwise scatter plot
pairs(~ Date + Age + Distance + Stores + Latitude + Longitude + Price)# there is need to transform "Distance"

data_training <- data_training %>%
  mutate(log_distance = log(Distance)) # Transformation of variable 'Distance' 
detach(data_training)

attach(data_training)

pairs(~ Date + Age + log_distance + Stores + Latitude + Longitude + Price)
subset(data_training, Price > 100) # A point that seem to be extreme in Price is case No. 271

# Taking out this point and fitting the model
data_training <- data_training[-72, ]

detach(data_training)

attach(data_training)
pairs(~ Date + Age + log_distance + Stores + Latitude + Longitude + Price)

lm1 = lm(Price ~ Date + Age + log_distance + Stores + Latitude + Longitude, data = data_training)
summary(lm1)

library(MASS)
stepAIC(lm2, direction = "backward", trace = FALSE)$anova 

lm2 = lm(Price ~ Date + Age + log_distance + Stores + Latitude, data = data_training)
summary(lm2)

lm3 = lm(Price ~ Date + Age + log_distance + Stores + Latitude - 1, data = data_training)
summary(lm3)
# calculating the Cp values
explanatory = with(data_training, cbind(Date, Age, log_distance, Stores, Latitude, -1))
findcp=with(data_training, leaps(explanatory, Price, method = "Cp"))
findcp

plot(lm2, 1:2)

data_training <- data_training[-c(19, 129, 138), ]
refitting the mode
lm2 = lm(Price ~ Date + Age + log_distance + Stores + Latitude, data = data_training)
summary(lm2)

# case influence statistics

#cooks's distance
plot(lm2, which = 4)
# studentized residuals
plot(1:246,studres(lm2))
abline(h=c(-2,2))

library(broom)
lm2 %>%
  augment() %>%
  mutate(residual = Price - .fitted ) %>%
  mutate(sq_residual = residual^2) %>%
  summarize(rmse = sqrt(mean(sq_residual)))
detach(data_training)
#testing
data_test = read.table("final_test.csv", header=T, sep=",")
attach(data_test)

data_test$Date <- as.integer(Date)
data_test <- data_test %>%
  mutate(Date = ifelse(Date == 2012, 1, 0))

pairs(~ Date + Age + Distance + Stores + Latitude + Longitude + Price)

data_test <- data_test %>%
  mutate(log_distance = log(Distance))
detach(data_training)
attach(data_test)
pairs(~ Date + Age + log_distance + Stores + Latitude + Longitude + Price)

lm2 %>%
  augment(newdata = data_test) %>%
  mutate(residual = Price - .fitted ) %>%
  mutate(sq_residual = residual^2) %>%
  summarize(rmse = sqrt(mean(sq_residual)))
detach(data_test)

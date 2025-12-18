# -----------------------------
# IJC437 – Prediction Model
# High PM2.5 events from meteorology
# Logistic Regression + Random Forest
# -----------------------------

# Packages
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(pROC)
library(caret)
library(ranger)

# -----------------------------
# 1) Load and clean PM2.5 data
# -----------------------------
data_path <- "Dataset/pm"  

files <- list.files(data_path, pattern = "\\.csv$", full.names = TRUE)
if (length(files) == 0) stop("No CSV files found in Dataset/PM (check folder name/path).")

air_all <- files %>%
  lapply(read_csv, show_col_types = FALSE) %>%
  bind_rows()

air_all <- air_all %>%
  mutate(
    datetime_clean = gsub("Z", "", datetimeUtc),
    datetime       = ymd_hms(datetime_clean, tz = "GMT", quiet = TRUE)
  ) %>%
  filter(!is.na(datetime))

# -----------------------------
# 2) Load and clean wind data
# -----------------------------
wind_raw <- read.csv("Dataset/WIND/wind.csv")

wind_clean <- wind_raw[-c(1, 2), 1:3]
names(wind_clean) <- c("time", "wind_speed_10m", "wind_direction_10m")

wind_clean <- wind_clean %>%
  mutate(
    time               = as.POSIXct(time, format = "%Y-%m-%dT%H:%M", tz = "GMT"),
    wind_speed_10m     = as.numeric(wind_speed_10m),
    wind_direction_10m = as.numeric(wind_direction_10m)
  ) %>%
  filter(!is.na(time), !is.na(wind_speed_10m), !is.na(wind_direction_10m))

wind_df <- wind_clean %>%
  transmute(
    date = time,
    wind_speed     = wind_speed_10m / 3.6,   # km/h -> m/s
    wind_direction = wind_direction_10m
  )

# -----------------------------
# 3) Merge PM2.5 and wind data (hourly)
# -----------------------------
pm_hourly <- air_all %>%
  transmute(
    date = datetime,
    pm25 = value
  ) %>%
  filter(!is.na(date), !is.na(pm25))

# Make timestamps align (hourly)
pm_hourly <- pm_hourly %>% mutate(date = floor_date(date, "hour"))
wind_df   <- wind_df   %>% mutate(date = floor_date(date, "hour"))

pm_wind_hourly <- pm_hourly %>%
  inner_join(wind_df, by = "date")

cat("Merged rows:", nrow(pm_wind_hourly), "\n")
if (nrow(pm_wind_hourly) == 0) stop("Join returned 0 rows. Check datetime alignment/timezone.")

# -----------------------------
# 4) Feature engineering
# -----------------------------
df <- pm_wind_hourly %>%
  filter(!is.na(pm25), !is.na(wind_speed), !is.na(wind_direction)) %>%
  mutate(
    high_pm25 = ifelse(pm25 >= 15, 1, 0),   # threshold = 15
    wd_rad = wind_direction * pi / 180,
    wd_sin = sin(wd_rad),
    wd_cos = cos(wd_rad),
    hour  = hour(date),
    month = month(date),
    wday  = wday(date, week_start = 1)
  ) %>%
  select(date, pm25, high_pm25, wind_speed, wd_sin, wd_cos, hour, month, wday) %>%
  arrange(date)

cat("\nClass balance:\n")
print(table(df$high_pm25))
print(prop.table(table(df$high_pm25)))

# -----------------------------
# 5) Train/Test split (time-aware)
# -----------------------------
split_point <- floor(0.8 * nrow(df))
train <- df[1:split_point, ]
test  <- df[(split_point + 1):nrow(df), ]

cat("\nTrain rows:", nrow(train), " Test rows:", nrow(test), "\n")

cutoff <- 0.5

# ============================================================
# MODEL 1: Logistic Regression
# ============================================================
model_logitic <- glm(
  high_pm25 ~ wind_speed + wd_sin + wd_cos + hour + month + wday,
  data = train,
  family = binomial()
)

cat("\n--- Logistic Regression Summary ---\n")
print(summary(model_logitic))

test$prob_high_logitic <- predict(model_logitic, newdata = test, type = "response")
test$pred_high_logitic <- ifelse(test$prob_high_logitic >= cutoff, 1, 0)

cm_logitic <- caret::confusionMatrix(
  factor(test$pred_high_logitic, levels = c(0,1)),
  factor(test$high_pm25, levels = c(0,1))
)
cat("\n--- Logistic Confusion Matrix ---\n")
print(cm_logitic)

roc_logitic <- pROC::roc(test$high_pm25, test$prob_high_logitic, quiet = TRUE)
auc_logitic <- pROC::auc(roc_logitic)
cat("\nLogistic AUC:", as.numeric(auc_logitic), "\n")

# ============================================================
# MODEL 2: Random Forest (ranger)
# ============================================================
train_rf <- train %>%
  mutate(high_pm25 = factor(high_pm25, levels = c(0,1), labels = c("No", "Yes")))

test_rf <- test %>%
  mutate(high_pm25 = factor(high_pm25, levels = c(0,1), labels = c("No", "Yes")))

rf_model <- ranger(
  high_pm25 ~ wind_speed + wd_sin + wd_cos + hour + month + wday,
  data = train_rf,
  probability = TRUE,
  num.trees = 500,
  mtry = 3,
  min.node.size = 20,
  importance = "permutation",
  seed = 437
)

cat("\n--- Random Forest Model ---\n")
print(rf_model)

rf_pred <- predict(rf_model, data = test_rf)$predictions
test$prob_high_rf <- rf_pred[, "Yes"]
test$pred_high_rf <- ifelse(test$prob_high_rf >= cutoff, 1, 0)

cm_rf <- caret::confusionMatrix(
  factor(test$pred_high_rf, levels = c(0,1)),
  factor(test$high_pm25, levels = c(0,1))
)
cat("\n--- RF Confusion Matrix ---\n")
print(cm_rf)

roc_rf <- pROC::roc(test$high_pm25, test$prob_high_rf, quiet = TRUE)
auc_rf <- pROC::auc(roc_rf)
cat("\nRF AUC:", as.numeric(auc_rf), "\n")

# ============================================================
# 6) Compare models (AUC + accuracy + sensitivity + specificity)
# ============================================================
compare_models <- data.frame(
  Model = c("Logistic", "Random Forest"),
  AUC = c(as.numeric(auc_logitic), as.numeric(auc_rf)),
  Accuracy = c(cm_logitic$overall["Accuracy"], cm_rf$overall["Accuracy"]),
  Sensitivity = c(cm_logitic$byClass["Sensitivity"], cm_rf$byClass["Sensitivity"]),
  Specificity = c(cm_logitic$byClass["Specificity"], cm_rf$byClass["Specificity"])
)

cat("\n--- Model Comparison ---\n")
print(compare_models)

# ============================================================
# 7) Plots: ROC curves + RF feature importance
# ============================================================
plot(roc_logitic, main = "ROC: Logistic vs Random Forest")
plot(roc_rf, add = TRUE)
legend(
  "bottomright",
  legend = c(paste0("Logistic AUC = ", round(as.numeric(auc_logitic), 3)),
             paste0("RF AUC = ", round(as.numeric(auc_rf), 3))),
  lty = 1, bty = "n"
)

# RF feature importance
importance_df <- data.frame(
  feature = names(rf_model$variable.importance),
  importance = as.numeric(rf_model$variable.importance)
) %>%
  arrange(desc(importance))

cat("\n--- RF Feature Importance ---\n")
print(importance_df)

ggplot(importance_df, aes(x = reorder(feature, importance), y = importance)) +
  geom_col(fill = "#4C72B0") +
  coord_flip() +
  labs(
    title = "Random Forest Feature Importance (Permutation)",
    x = NULL,
    y = "Importance"
  ) +
  theme_minimal()

# ============================================================
# 8) Plot: predicted risk vs wind speed
# ============================================================
ggplot(test, aes(x = wind_speed, y = prob_high_logitic)) +
  geom_point(color  = "#4C72B0", alpha = 0.15) +
  geom_smooth(color = "#DD8452", se = TRUE) +
  labs(
    title = "Logistic: Predicted probability of high PM2.5 vs wind speed",
    x = "Wind speed (m/s)",
    y = "Predicted P(high PM2.5)"
  ) +
  theme_minimal()

ggplot(test, aes(x = wind_speed , y = prob_high_rf)) +
  geom_point(color  = "#4C72B0", alpha = 0.15) +
  geom_smooth(color = "#DD8452") +
  labs(
    title = "Random Forest: Predicted probability of high PM2.5 vs wind speed",
    x = "Wind speed (m/s)",
    y = "Predicted P(high PM2.5)"
  ) +
  theme_minimal()

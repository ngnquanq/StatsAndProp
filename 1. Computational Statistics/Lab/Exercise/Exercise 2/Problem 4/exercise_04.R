# Exercise 4: Bootstrap Aggregating (Bagging) and Random Forest
# Author: Quang Nguyen

# Load necessary libraries
# We use 'rpart' for decision trees, 'randomForest' for Random Forest
if (!require(rpart)) install.packages("rpart", repos = "http://cran.us.r-project.org")
if (!require(randomForest)) install.packages("randomForest", repos = "http://cran.us.r-project.org")
if (!require(pROC)) install.packages("pROC", repos = "http://cran.us.r-project.org") # For AUC

library(rpart)
library(randomForest)
library(pROC)

# --- Helper Functions ---

# Function to calculate accuracy
calc_accuracy <- function(actual, predicted) {
    mean(actual == predicted)
}

# Function to calculate AUC
calc_auc <- function(actual, prob_class_1) {
    roc_obj <- roc(actual, prob_class_1, quiet = TRUE)
    return(auc(roc_obj))
}

# --- Data Loading and Preprocessing ---

data <- read.csv("breast_cancer.csv")

# diagnosis is the target. 'M' (Malignant) = 1, 'B' (Benign) = 0
data$diagnosis <- factor(ifelse(data$diagnosis == "M", 1, 0))

# Remove 'id' column as it's not a predictor.
# Also remove the last column which appears empty in some CSV reads if trailing comma exists
data$id <- NULL
if (all(is.na(data[, ncol(data)]))) {
    data <- data[, -ncol(data)]
}

cat("Data loaded. Dimensions:", dim(data), "\n")
cat("Class distribution:\n")
print(table(data$diagnosis))

# --- Part (a): Single Decision Tree & Stability ---

run_single_tree <- function(data, seed = 123) {
    set.seed(seed)
    n <- nrow(data)
    train_idx <- sample(1:n, size = 0.7 * n)
    train_data <- data[train_idx, ]
    test_data <- data[-train_idx, ]

    # Train rpart tree
    tree_model <- rpart(diagnosis ~ ., data = train_data, method = "class")

    # Predict
    prob_pred <- predict(tree_model, test_data, type = "prob")[, 2] # Prob of class 1
    class_pred <- ifelse(prob_pred > 0.5, 1, 0)

    acc <- calc_accuracy(test_data$diagnosis, class_pred)
    auc_val <- calc_auc(test_data$diagnosis, prob_pred)

    return(list(accuracy = acc, auc = auc_val))
}

cat("\n--- Part (a): Single Tree Results ---\n")
res_a1 <- run_single_tree(data, seed = 123)
cat(sprintf("Seed 123: Accuracy = %.4f, AUC = %.4f\n", res_a1$accuracy, res_a1$auc))

res_a2 <- run_single_tree(data, seed = 456)
cat(sprintf("Seed 456: Accuracy = %.4f, AUC = %.4f\n", res_a2$accuracy, res_a2$auc))
cat("Observation: Results vary with random seed (instability).\n")


# --- Part (b): Manual Bagging Implementation ---

run_bagging <- function(data, B = 200, seed = 123) {
    set.seed(seed)
    n <- nrow(data)
    train_idx <- sample(1:n, size = 0.7 * n)
    train_data <- data[train_idx, ]
    test_data <- data[-train_idx, ]

    # Store predictions from all B trees
    n_test <- nrow(test_data)
    all_probs <- matrix(0, nrow = n_test, ncol = B)

    for (b in 1:B) {
        # Bootstrap sample
        boot_idx <- sample(1:nrow(train_data), size = nrow(train_data), replace = TRUE)
        boot_data <- train_data[boot_idx, ]

        # Train tree (sometimes a tree might be just a root if data is too homogeneous, rpart handles this)
        tree_model <- rpart(diagnosis ~ ., data = boot_data, method = "class")

        # Predict probabilities
        pred <- predict(tree_model, test_data, type = "prob")[, 2]
        all_probs[, b] <- pred
    }

    # Aggregate: Average Probability
    avg_probs <- rowMeans(all_probs)
    bag_pred <- ifelse(avg_probs > 0.5, 1, 0)

    acc <- calc_accuracy(test_data$diagnosis, bag_pred)
    auc_val <- calc_auc(test_data$diagnosis, avg_probs)

    return(list(accuracy = acc, auc = auc_val))
}

cat("\n--- Part (b): Bagging Results (B=200) ---\n")
res_b <- run_bagging(data, B = 200, seed = 123)
cat(sprintf("Bagging Accuracy = %.4f, AUC = %.4f\n", res_b$accuracy, res_b$auc))


# --- Part (c) & (d): Variance Reduction & Random Forest Comparison ---

cat("\n--- Part (c) & (d): Variance Reduction Simulation (50 Repeats) ---\n")
cat("This may take a minute...\n")

n_repeats <- 50
acc_single <- numeric(n_repeats)
acc_bagging <- numeric(n_repeats)
acc_rf <- numeric(n_repeats)

set.seed(999) # Master seed for simulation loop

for (i in 1:n_repeats) {
    if (i %% 5 == 0) cat(sprintf("Iteration %d/%d...\n", i, n_repeats))

    n <- nrow(data)
    train_idx <- sample(1:n, size = 0.7 * n)
    train_data <- data[train_idx, ]
    test_data <- data[-train_idx, ]

    # 1. Single Tree
    tree_model <- rpart(diagnosis ~ ., data = train_data, method = "class")
    tree_pred_prob <- predict(tree_model, test_data, type = "prob")[, 2]
    tree_pred_class <- ifelse(tree_pred_prob > 0.5, 1, 0)
    acc_single[i] <- calc_accuracy(test_data$diagnosis, tree_pred_class)

    # 2. Bagging (B=200) - Manual implementation inside loop for efficiency reuse?
    # Actually calling rpart 200 times is slow. But let's run it correctly as requested.
    # Optimizing: Minimal control parameters to speed up rpart? Default is fine for demonstration.
    bag_probs <- numeric(nrow(test_data))
    B <- 200
    for (b in 1:B) {
        boot_idx <- sample(1:nrow(train_data), replace = TRUE)
        # Using 'control' to speed up slightly if needed, but defaults are safer for comparison
        fit <- rpart(diagnosis ~ ., data = train_data[boot_idx, ], method = "class")
        bag_probs <- bag_probs + predict(fit, test_data, type = "prob")[, 2]
    }
    bag_probs <- bag_probs / B
    bag_pred_class <- ifelse(bag_probs > 0.5, 1, 0)
    acc_bagging[i] <- calc_accuracy(test_data$diagnosis, bag_pred_class)

    # 3. Random Forest (ntree=200)
    # randomForest automatically does bagging + feature selection
    rf_model <- randomForest(diagnosis ~ ., data = train_data, ntree = 200)
    rf_pred_class <- predict(rf_model, test_data, type = "response") # Returns factor class directly
    # Need to convert factor to numeric 0/1 for comparison
    # levels are 0, 1. predict returns factor "0", "1".
    rf_pred_numeric <- as.numeric(as.character(rf_pred_class))
    acc_rf[i] <- calc_accuracy(test_data$diagnosis, rf_pred_numeric)
}

# Statistics
mean_single <- mean(acc_single)
var_single <- var(acc_single)

mean_bagging <- mean(acc_bagging)
var_bagging <- var(acc_bagging)

mean_rf <- mean(acc_rf)
var_rf <- var(acc_rf)

var_reduction_bagging <- (var_single - var_bagging) / var_single * 100
var_reduction_rf <- (var_single - var_rf) / var_single * 100 # Just for curiosity

cat("\nResults (over 50 repeats):\n")
cat(sprintf("Single Tree: Mean Acc = %.4f, Variance = %.6f\n", mean_single, var_single))
cat(sprintf("Bagging    : Mean Acc = %.4f, Variance = %.6f\n", mean_bagging, var_bagging))
cat(sprintf("Random Frst: Mean Acc = %.4f, Variance = %.6f\n", mean_rf, var_rf))
cat(sprintf("Variance Reduction (Bagging vs Single): %.2f%%\n", var_reduction_bagging))

if (!interactive()) {
    # Plotting
    png("bagging_variance_comparison.png", width = 800, height = 600)
    boxplot(list(SingleTree = acc_single, Bagging = acc_bagging, RandomForest = acc_rf),
        main = "Accuracy Distribution: Tree vs Bagging vs Random Forest",
        ylab = "Accuracy",
        col = c("lightblue", "orange", "lightgreen")
    )
    grid()
    dev.off()
    cat("Generated bagging_variance_comparison.png\n")
}

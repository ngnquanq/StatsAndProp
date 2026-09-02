# Machine Learning Final Exam Practice

**Based on:** Lec_00_IntroML, Lec_01_LinearReg, Lec_02_LogisticReg, and Lec_03_BeyondDS  
**Format:** 100 multiple-choice questions  
**Instructions:** Choose the best answer for each question. The answer key is at the end.

## Part I — Introduction to Machine Learning (Questions 1–15)

1. Which statement best describes machine learning?
   - A. Computers follow only explicitly programmed rules
   - B. Computers learn patterns from data and use them to make decisions
   - C. Computers store data without analyzing it
   - D. Computers replace all human decision-making

2. Which sequence correctly represents the basic machine-learning workflow?
   - A. Train → collect → test → prepare → use
   - B. Collect → prepare → choose a model → train → test → use on new data
   - C. Choose a model → test → collect → train
   - D. Prepare → test → collect → deploy

3. In supervised learning, the training examples contain:
   - A. Inputs only
   - B. Labels only
   - C. Both input features and correct labels
   - D. Rewards and penalties only

4. Which task is most naturally a supervised-learning problem?
   - A. Grouping customers without predefined groups
   - B. Predicting whether an email is spam using labeled emails
   - C. Discovering topics in unlabeled articles
   - D. Letting a robot learn through rewards

5. Which task is most naturally an unsupervised-learning problem?
   - A. Predicting house prices from labeled examples
   - B. Diagnosing diseases using labeled scans
   - C. Grouping customers according to behavior without labels
   - D. Training a game agent using rewards

6. Unsupervised learning primarily learns from:
   - A. Labeled data
   - B. Unlabeled data
   - C. Rewards and penalties
   - D. Handwritten rules

7. In reinforcement learning, an agent learns mainly by:
   - A. Memorizing labels
   - B. Interacting with an environment and receiving rewards or penalties
   - C. Grouping similar observations
   - D. Minimizing only the mean squared error

8. The main goal of a reinforcement-learning policy is to:
   - A. Maximize cumulative reward over time
   - B. Eliminate all input features
   - C. Create labels for a dataset
   - D. Minimize the number of actions

9. Which pairing is correct?
   - A. Supervised learning — grouping and pattern discovery only
   - B. Unsupervised learning — labeled prediction
   - C. Reinforcement learning — games and robotics
   - D. Reinforcement learning — spreadsheet formatting

10. In a loan approval model, which is the most likely label?
    - A. Applicant income
    - B. Applicant age
    - C. Approved or not approved
    - D. Credit history length

11. In customer churn prediction, which is the most likely feature?
    - A. Whether the customer eventually leaves
    - B. The customer's usage history
    - C. The model's final prediction
    - D. The loss function

12. Which tool is listed in the slides as a machine-learning library?
    - A. Microsoft Word
    - B. scikit-learn
    - C. PowerPoint
    - D. Photoshop

13. Which platform is listed as useful for machine-learning work?
    - A. Google Colab
    - B. Adobe Reader
    - C. Microsoft Paint
    - D. VLC

14. A movie recommendation system is an example of:
    - A. A real-life machine-learning application
    - B. A database with no learning component
    - C. A reinforcement-learning environment in every case
    - D. A feature-scaling method

15. Which relationship is correct?
    - A. AI is a subfield of deep learning
    - B. Deep learning contains all of AI
    - C. Machine learning is a branch of AI, and deep learning is a subfield of ML
    - D. AI, ML, and deep learning are unrelated

## Part II — Linear Regression and Optimization (Questions 16–55)

16. In the house-price example, the size of a house is:
    - A. The label
    - B. A feature
    - C. The loss
    - D. The learning rate

17. In the same example, the house price is:
    - A. A target label
    - B. A hyperparameter
    - C. A gradient
    - D. A batch

18. For `h(x) = θ₀ + θ₁x`, `θ₀` is usually called:
    - A. The batch size
    - B. The intercept or bias
    - C. The label
    - D. The epoch

19. For `h(x) = θ₀ + θ₁x`, `θ₁` controls:
    - A. The slope of the line
    - B. The number of samples
    - C. The class threshold
    - D. The test-set size

20. Good parameter values for a linear-regression model make:
    - A. Predictions close to the true training labels
    - B. Every feature equal to zero
    - C. The dataset larger
    - D. The learning rate infinite

21. Mean squared error is the average of:
    - A. The absolute features
    - B. The squared differences between predictions and true values
    - C. The model parameters
    - D. The class probabilities

22. A smaller MSE generally indicates:
    - A. A better fit to the evaluated data
    - B. A larger learning rate
    - C. More input features
    - D. A larger batch

23. Why is the least-squares loss often written with a factor of `1/(2n)`?
    - A. It forces all predictions to be positive
    - B. The factor 2 simplifies the derivative
    - C. It creates additional samples
    - D. It converts regression into classification

24. Training least-squares linear regression means finding parameters that:
    - A. Maximize the MSE
    - B. Minimize the loss function
    - C. Maximize the number of features
    - D. Minimize the dataset

25. Gradient descent begins by:
    - A. Choosing initial parameter values
    - B. Deleting the training set
    - C. Setting all labels to one
    - D. Selecting the test result

26. Which is the standard gradient-descent update?
    - A. `θⱼ ← θⱼ + α(∂J/∂θⱼ)`
    - B. `θⱼ ← θⱼ − α(∂J/∂θⱼ)`
    - C. `θⱼ ← α/J`
    - D. `θⱼ ← J − α`

27. In gradient descent, `α` represents:
    - A. The learning rate
    - B. The true label
    - C. The batch count
    - D. The bias feature

28. Why does gradient descent move in the negative-gradient direction?
    - A. The negative gradient points toward increasing loss
    - B. It generally points toward decreasing loss
    - C. It makes the dataset balanced
    - D. It changes regression into clustering

29. If the current parameter is to the right of a one-dimensional minimum and the derivative is positive, the update should move the parameter:
    - A. Further right
    - B. Left
    - C. Nowhere, regardless of learning rate
    - D. Randomly

30. If the derivative is negative, subtracting the derivative tends to move the parameter:
    - A. In the positive direction
    - B. In the negative direction
    - C. Directly to zero in every case
    - D. Outside the parameter space

31. Which can be used as a convergence condition?
    - A. The loss is below a small tolerance
    - B. The parameter change is below a small tolerance
    - C. Performance on an independent test set is sufficient
    - D. All of the above

32. Batch gradient descent calculates each update using:
    - A. One randomly chosen feature
    - B. The entire training dataset
    - C. One training example
    - D. The validation labels only

33. Stochastic gradient descent calculates each update using:
    - A. The entire dataset
    - B. A single data point
    - C. The test set
    - D. No data

34. Mini-batch gradient descent calculates each update using:
    - A. A small subset of training samples
    - B. Exactly one feature
    - C. The complete test set
    - D. Only mislabeled observations

35. The main difference among batch, stochastic, and mini-batch gradient descent is:
    - A. The amount of data used to compute each gradient update
    - B. Whether the task is supervised
    - C. The definition of a label
    - D. Whether a model has parameters

36. One iteration corresponds to:
    - A. Processing the complete dataset exactly once
    - B. Processing one batch and updating the model once
    - C. Completing the whole project lifecycle
    - D. Testing every possible model

37. One epoch corresponds to:
    - A. One parameter only
    - B. Processing the entire training dataset once
    - C. One test sample
    - D. One feature transformation

38. A dataset has 1,024 samples and a batch size of 64. How many iterations are in one epoch?
    - A. 8
    - B. 16
    - C. 64
    - D. 1,024

39. Which is an advantage of batch gradient descent?
    - A. It always requires very little memory
    - B. Its updates are generally smooth and stable
    - C. It uses only one sample
    - D. Its updates are maximally noisy

40. Which is a disadvantage of batch gradient descent on very large datasets?
    - A. It cannot calculate gradients
    - B. It may be slow and memory intensive
    - C. It never converges smoothly
    - D. It uses no training data

41. Which is an advantage of stochastic gradient descent?
    - A. It processes one point at a time and uses little memory
    - B. It always follows a perfectly smooth path
    - C. It requires the entire dataset in memory for every update
    - D. It has no update noise

42. A common disadvantage of stochastic gradient descent is:
    - A. Noisy and potentially unstable convergence
    - B. An inability to process large datasets
    - C. No parameter updates
    - D. A requirement that every feature be binary

43. Mini-batch gradient descent is often viewed as:
    - A. A compromise between batch GD and SGD
    - B. A classification metric
    - C. A form of data labeling
    - D. A replacement for a test set

44. Which is a hyperparameter?
    - A. A coefficient learned directly from training data
    - B. The batch size chosen before training
    - C. A true training label
    - D. A prediction produced by the model

45. Which item is NOT listed as a model hyperparameter in the slides?
    - A. Learning rate
    - B. Batch size
    - C. Regularization weight
    - D. The observed target label of a sample

46. If the learning rate is much too small, training will usually:
    - A. Converge slowly
    - B. Instantly diverge
    - C. Eliminate all error in one update
    - D. Change into unsupervised learning

47. If the learning rate is too large, gradient descent may:
    - A. Overshoot or fail to converge
    - B. Always find the exact minimum in one step
    - C. Stop using gradients
    - D. Automatically regularize all parameters

48. Polynomial regression can still be called linear regression because the model is:
    - A. Linear in its learnable parameters
    - B. Always a straight line in the original input
    - C. Free of parameters
    - D. Used only for classification

49. A model that is too simple to capture the underlying pattern is:
    - A. Overfitting
    - B. Underfitting
    - C. Standardizing
    - D. Regularizing

50. A model that fits training details and noise but performs poorly on new data is:
    - A. Underfitting
    - B. Overfitting
    - C. Normalizing
    - D. Clustering

51. What is the main purpose of a validation set?
    - A. To fit every model parameter directly
    - B. To select models or hyperparameters and monitor generalization
    - C. To replace all training data
    - D. To create input features

52. To avoid data leakage during standardization, the mean and standard deviation should be:
    - A. Calculated separately from each test sample
    - B. Estimated from the training set and then applied to validation and test sets
    - C. Estimated only from the test set
    - D. Chosen randomly

53. Standardization transforms a feature so that it has approximately:
    - A. Zero mean and unit variance
    - B. Minimum 0 and maximum 1 only
    - C. Unit sum
    - D. Binary values

54. Min-max scaling, as presented in the slides, maps feature values to:
    - A. `[−1, 1]`
    - B. `[0, 1]`
    - C. `(−∞, ∞)`
    - D. `{0, 1}` only

55. Which statement about L2 regularization is correct?
    - A. It adds a penalty proportional to squared coefficient values
    - B. It always increases coefficient magnitudes
    - C. It removes the model-fit term from the objective
    - D. It is identical to min-max scaling

## Part III — Logistic Regression and Classification (Questions 56–80)

56. A classification model assigns inputs to:
    - A. One or more predefined categories
    - B. Continuous values only
    - C. Random batches
    - D. Learning rates

57. Which is a binary-classification problem?
    - A. Predicting an exact house price
    - B. Classifying a tumor as malignant or benign
    - C. Grouping unlabeled customers
    - D. Predicting daily temperature as a number

58. In binary classification, the positive class is conventionally labeled:
    - A. `−1`
    - B. `0`
    - C. `1`
    - D. `2`

59. If `P(spam | x) = 0.8`, then `P(not spam | x)` equals:
    - A. 0.1
    - B. 0.2
    - C. 0.8
    - D. 1.8

60. Logistic regression maps a linear combination of inputs through:
    - A. The sigmoid function
    - B. Min-max scaling
    - C. The L2 norm only
    - D. A confusion matrix

61. The output range of the sigmoid function is:
    - A. `(−∞, ∞)`
    - B. `[0, 255]`
    - C. Between 0 and 1
    - D. Integers only

62. The sigmoid function is:
    - A. `σ(z) = 1/(1 + e^(−z))`
    - B. `σ(z) = z²`
    - C. `σ(z) = 1/z`
    - D. `σ(z) = e^(−z)`

63. With a threshold of 0.5, a predicted probability of 0.88 is classified as:
    - A. Class 0
    - B. Class 1
    - C. Both classes
    - D. Unlabeled

64. Increasing the decision threshold above 0.5 generally makes the model:
    - A. Require stronger evidence before predicting the positive class
    - B. Predict more positive cases automatically
    - C. Produce probabilities above 1
    - D. Become a regression model

65. Lowering the decision threshold generally:
    - A. Produces fewer positive predictions
    - B. Produces more positive predictions
    - C. Removes the sigmoid function
    - D. Makes every probability zero

66. Why is MSE not preferred in the slides for logistic-regression training?
    - A. It can produce a non-convex objective with the sigmoid model
    - B. It cannot be calculated
    - C. It always gives a zero loss
    - D. It requires unlabeled data

67. Which loss is used for binary logistic regression in the slides?
    - A. Binary cross-entropy
    - B. Image reconstruction loss
    - C. Unit-vector loss
    - D. Batch-size loss

68. For one sample, binary cross-entropy can be written as:
    - A. `−y log(h) − (1−y) log(1−h)`
    - B. `y + h`
    - C. `(y + h)²`
    - D. `y/h`

69. When the true label is `y = 1`, BCE becomes:
    - A. `−log(h)`
    - B. `−log(1−h)`
    - C. `h²`
    - D. `1−h²`

70. When `y = 1` and the predicted probability `h` approaches 0, BCE:
    - A. Approaches 0
    - B. Approaches infinity
    - C. Remains exactly 1
    - D. Becomes negative

71. When `y = 0` and the predicted probability `h` approaches 1, BCE:
    - A. Approaches infinity
    - B. Approaches 0
    - C. Becomes the MSE
    - D. Becomes a class label

72. Logistic-regression parameters can be optimized using:
    - A. Gradient descent
    - B. A confusion matrix alone
    - C. Data annotation alone
    - D. RGB scaling

73. Softmax regression is a generalization of logistic regression for:
    - A. Multi-class classification
    - B. Unsupervised clustering
    - C. Audio compression
    - D. Linear scaling

74. The probabilities produced by softmax across all classes sum to:
    - A. 0
    - B. 0.5
    - C. 1
    - D. The number of features

75. In one-hot encoding for three classes, a correct label for the first class can be:
    - A. `[1, 0, 0]`
    - B. `[1, 1, 1]`
    - C. `[0.5, 0.5, 0.5]`
    - D. `[3]` only

76. A confusion matrix contains counts of:
    - A. TP, FP, TN, and FN
    - B. Learning rates and batch sizes
    - C. Means and standard deviations
    - D. Epochs and iterations only

77. Precision is calculated as:
    - A. `TP/(TP + FP)`
    - B. `TP/(TP + FN)`
    - C. `(TP + TN)/N`
    - D. `TN/(TN + FN)`

78. Recall is calculated as:
    - A. `TP/(TP + FP)`
    - B. `TP/(TP + FN)`
    - C. `TN/(TN + FP)`
    - D. `FP/(FP + FN)`

79. In the email example, `TP = 100`, `FP = 10`, `FN = 5`, and `TN = 50`. What is the accuracy?
    - A. `100/110`
    - B. `100/105`
    - C. `150/165`
    - D. `50/165`

80. The F1 score is the:
    - A. Arithmetic mean of precision and accuracy
    - B. Harmonic mean of precision and recall
    - C. Difference between recall and precision
    - D. Sum of TP and TN

## Part IV — Complex Data, AI Production, and Careers (Questions 81–100)

81. Traditional tabular data is commonly organized as:
    - A. Rows and columns
    - B. Audio waves only
    - C. Pixel grids only
    - D. Neural-network layers only

82. Which is a complex, unstructured data type discussed in the slides?
    - A. Image
    - B. Text
    - C. Audio
    - D. All of the above

83. A digital image is typically represented as:
    - A. An array or grid of pixels
    - B. A confusion matrix
    - C. A list of class thresholds only
    - D. An SQL query only

84. In a standard RGB image, each pixel contains:
    - A. Two class labels
    - B. Three color-intensity values
    - C. One audio signal
    - D. Four loss functions

85. If each RGB channel uses 8 bits, how many bits are required for an uncompressed `32 × 32 × 3` image?
    - A. 3,072 bits
    - B. 8,192 bits
    - C. 24,576 bits
    - D. 786,432 bits

86. In MNIST handwritten-digit classification, the inputs and labels are:
    - A. Grayscale images and corresponding digits
    - B. Audio clips and speakers
    - C. Reviews and prices
    - D. Customer ages and loan amounts

87. Computer vision focuses on:
    - A. Interpreting visual data from images or videos
    - B. Managing only relational databases
    - C. Calculating only financial ratios
    - D. Creating spreadsheet formulas

88. Natural language processing focuses on enabling machines to:
    - A. Understand, interpret, and generate human language
    - B. Change RGB pixel intensities only
    - C. Optimize delivery routes only
    - D. Scale numerical features only

89. Speech-to-text belongs mainly to:
    - A. Speech and sound processing
    - B. Min-max scaling
    - C. Linear regression only
    - D. Data quality auditing only

90. Credit scoring is an AI application commonly associated with:
    - A. Banking and finance
    - B. Agriculture
    - C. Gaming
    - D. Image compression

91. In gaming, reinforcement learning improves an agent's strategy through:
    - A. Trial, interaction, and reward
    - B. Fixed spreadsheet formulas
    - C. Unlabeled clustering only
    - D. Removing all actions

92. The AI lifecycle described in the slides is:
    - A. Iterative, with stages revisited during development and deployment
    - B. Strictly one-directional and never repeated
    - C. Limited to model training
    - D. Complete as soon as data is collected

93. Which activity belongs to “Acquire and explore data”?
    - A. Conduct exploratory data analysis
    - B. Define only the final API URL
    - C. Calculate employee salaries
    - D. Stop all model monitoring

94. Target leakage should be:
    - A. Identified and removed
    - B. Added to improve test accuracy
    - C. Used as a model-deployment tool
    - D. Treated as a learning rate

95. Which activity belongs to the model-data stage?
    - A. Variable selection and candidate-model building
    - B. Data encryption only
    - C. Writing movie reviews
    - D. Choosing pixel colors manually

96. Model deployment means:
    - A. Making a trained model available for real-world use
    - B. Deleting the trained model
    - C. Collecting data without using it
    - D. Converting labels into features

97. A deployed model may be accessed through:
    - A. A REST API or gRPC
    - B. A confusion matrix only
    - C. An epoch only
    - D. A handwritten table only

98. Which practice helps protect confidential data?
    - A. Encryption, secure transfer, and anonymization
    - B. Publishing all raw personal data
    - C. Removing authentication
    - D. Increasing the learning rate

99. Which role primarily builds and maintains data systems, pipelines, and AI infrastructure?
    - A. AI and data engineer
    - B. Business analyst
    - C. Marketing customer
    - D. Medical annotator

100. Which comparison best matches the slides?
     - A. A business analyst is generally more business-focused, while a data analyst is more data-focused
     - B. A data analyst never gathers or cleans data
     - C. A business analyst never communicates findings
     - D. The two roles have no connection to data

---

## Answer Key

1. B  
2. B  
3. C  
4. B  
5. C  
6. B  
7. B  
8. A  
9. C  
10. C  
11. B  
12. B  
13. A  
14. A  
15. C  
16. B  
17. A  
18. B  
19. A  
20. A  
21. B  
22. A  
23. B  
24. B  
25. A  
26. B  
27. A  
28. B  
29. B  
30. A  
31. D  
32. B  
33. B  
34. A  
35. A  
36. B  
37. B  
38. B  
39. B  
40. B  
41. A  
42. A  
43. A  
44. B  
45. D  
46. A  
47. A  
48. A  
49. B  
50. B  
51. B  
52. B  
53. A  
54. B  
55. A  
56. A  
57. B  
58. C  
59. B  
60. A  
61. C  
62. A  
63. B  
64. A  
65. B  
66. A  
67. A  
68. A  
69. A  
70. B  
71. A  
72. A  
73. A  
74. C  
75. A  
76. A  
77. A  
78. B  
79. C  
80. B  
81. A  
82. D  
83. A  
84. B  
85. C  
86. A  
87. A  
88. A  
89. A  
90. A  
91. A  
92. A  
93. A  
94. A  
95. A  
96. A  
97. A  
98. A  
99. A  
100. A

## Score Guide

- **90–100:** Excellent — review only the questions you missed.
- **75–89:** Good — revisit formulas, optimization, and evaluation metrics.
- **60–74:** Developing — review each lecture and retake the test.
- **Below 60:** Start with the lecture summaries, then practice one section at a time.

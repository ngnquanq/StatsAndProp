# Advanced Machine Learning Final Exam

**Level:** advanced undergraduate through introductory graduate  
**Length:** 100 questions, 200 points; suggested 5–7 hours  
**Rules:** calculator permitted; do not execute code; show work for Questions 51–100.

## Notation and compact formula sheet

- Data matrix `X ∈ R^(n×p)`, response `y`, parameters `β`; an intercept column is stated when used.
- `MSE = n⁻¹Σ(yᵢ-ŷᵢ)²`; `σ(z)=1/(1+e⁻ᶻ)`; binary log-loss is `-Σ[y log p+(1-y)log(1-p)]`.
- `precision=TP/(TP+FP)`, `recall=TP/(TP+FN)`, `F1=2PR/(P+R)`.
- Unless stated otherwise, logarithms are natural, regularization excludes the intercept, and ties at a classification threshold predict class 1.

## Part A — Advanced multiple choice (Questions 1–50, 1 point each)

Choose exactly one best answer.

1. A model has training MSE 2 and validation MSE 25. Adding observations from the same population while holding model class fixed most directly targets: A. approximation bias B. estimation variance C. label definition D. irreducible noise
2. If `X` has full column rank, the OLS solution is: A. `Xy` B. `(XXᵀ)⁻¹Xy` C. `(XᵀX)⁻¹Xᵀy` D. `Xᵀ(Xy)⁻¹`
3. Perfect multicollinearity primarily causes: A. non-unique OLS coefficients B. non-convex squared loss C. biased fitted values in every solution D. negative MSE
4. Under `y=Xβ+ε`, `E[ε|X]=0` is chiefly used to establish: A. normal residuals B. unbiasedness of OLS conditional on X C. equal variance D. independence among columns
5. Multiplying one feature by 100 without changing its coefficient initially makes gradient descent: A. invariant B. generally ill-conditioned C. convex only locally D. equivalent to L1
6. For a fixed learning rate on a convex quadratic, oscillating divergence most strongly suggests: A. rate too large B. rate too small C. excessive regularization D. label leakage
7. Ridge regression is especially useful when predictors are: A. all binary B. correlated and coefficient stability matters C. perfectly observed labels D. independent of the response
8. Increasing ridge `λ` generally: A. lowers training error monotonically B. increases coefficient norm C. increases bias and reduces variance D. produces exact zeros routinely
9. Compared with ridge, lasso more naturally: A. preserves all variables B. selects variables via exact zero coefficients C. removes the need for scaling D. guarantees causal effects
10. A high-degree polynomial has low training error and unstable validation error. The best first response is: A. add degree B. regularize or reduce degree C. evaluate on training data D. remove validation
11. In logistic regression, `βⱼ` is most directly interpreted as the change in: A. probability B. odds C. log-odds per unit change in `xⱼ` D. class label
12. Complete separation in unregularized logistic regression can make: A. MLE coefficients diverge B. sigmoid non-monotone C. log-loss negative D. all gradients zero initially
13. Logistic negative log-likelihood is convex because its Hessian has form: A. `-XᵀX` B. `XᵀWX` with `W` nonnegative diagonal C. `XXᵀ-I` D. `W-X`
14. If false negatives cost 20 times false positives, a reasonable response is usually to: A. raise the positive threshold B. lower the positive threshold C. maximize specificity only D. report accuracy only
15. ROC-AUC can remain high while precision is poor when: A. positives are rare B. classes are balanced C. the threshold is always zero D. probabilities are calibrated
16. Calibration asks whether: A. rankings are correct B. predicted 0.8 events occur about 80% of the time C. accuracy exceeds 0.8 D. residuals sum to zero
17. Which metric is threshold-free and emphasizes ranking positives above negatives? A. accuracy B. ROC-AUC C. F1 at 0.5 D. confusion matrix
18. A classifier predicts every case negative in a dataset with 1% positives. Its 99% accuracy demonstrates: A. excellent recall B. class imbalance can make accuracy misleading C. calibration D. leakage
19. Tuning hyperparameters on the test set primarily creates: A. regularization B. optimistic test bias C. underfitting D. covariate scaling
20. Nested cross-validation is chiefly used to: A. impute missing labels B. estimate generalization while tuning hyperparameters C. enlarge training data permanently D. balance classes
21. Preprocessing before cross-validation is dangerous because: A. scaling is stochastic B. validation-fold information may influence fitted transformations C. pipelines cannot scale D. test labels are required
22. For time-ordered demand forecasting, the safest split is usually: A. random K-fold B. future-to-past C. chronological rolling/forward validation D. leave-one-feature-out
23. Grouped CV is essential when: A. rows from one patient must not cross folds B. features have different units C. classes are balanced D. `p<n`
24. Stratification aims primarily to preserve: A. feature means B. class proportions across folds C. temporal order D. coefficient signs
25. A learning curve with high, similar training and validation errors suggests: A. high variance B. high bias C. leakage D. perfect fit
26. Bootstrap sampling differs from K-fold CV because bootstrap samples: A. never repeat rows B. use replacement C. require time order D. estimate only classification error
27. A decision tree split is selected to: A. maximize child impurity B. reduce weighted impurity C. maximize depth D. standardize inputs
28. Random forests reduce correlation among trees partly by: A. using identical features at each split B. random feature subsampling C. fitting trees sequentially to residuals D. removing bootstrap samples
29. Gradient boosting differs from random forests because boosting: A. fits learners sequentially to improve current errors B. cannot classify C. uses no trees D. averages independent full-depth trees
30. For an RBF SVM, a very large `γ` tends to produce: A. smoother boundaries B. highly local, potentially overfit boundaries C. linear regression D. stronger calibration guarantees
31. The soft-margin SVM parameter `C` controls the tradeoff between: A. margin violations and margin size B. trees and features C. precision and recall directly D. PCA variance and dimension
32. K-means minimizes: A. maximum pairwise distance B. within-cluster squared distances to centroids C. classification log-loss D. between-cluster similarity only
33. K-means is sensitive to feature scaling because it relies on: A. ranks B. Euclidean distances C. labels D. likelihood ratios
34. The first principal component is the unit direction that: A. minimizes projected variance B. maximizes projected variance C. maximizes class accuracy D. selects one original feature
35. PCA before a train/test split risks: A. label leakage only B. test-distribution leakage C. non-convexity D. integer overflow
36. Bagging is most effective for a base learner with: A. high variance B. high irreducible bias only C. no sensitivity to data D. zero complexity
37. In a neural network, ReLU helps relative to sigmoid hidden units mainly by: A. guaranteeing convexity B. mitigating saturation for positive activations C. outputting probabilities D. removing weights
38. Dropout during training can be viewed as: A. data leakage B. stochastic regularization C. exact Bayesian inference D. feature scaling
39. Cross-entropy with softmax is natural for: A. mutually exclusive multiclass outcomes B. continuous regression only C. clustering without labels D. PCA
40. Backpropagation is an efficient application of: A. Bayes rule B. the chain rule C. bootstrap sampling D. eigendecomposition
41. Convolutional networks exploit images through: A. parameter sharing and local connectivity B. one parameter per image C. sorted pixels D. label smoothing only
42. Word embeddings represent tokens as: A. one immutable class B. dense vectors where geometry can encode relationships C. confusion matrices D. scalar labels only
43. Concept drift means: A. `P(X)` changes only B. the predictive relationship or target concept changes C. files are corrupted D. a model is large
44. Covariate shift commonly denotes change in: A. `P(X)` while `P(Y|X)` is stable B. `P(Y|X)` only C. the loss formula D. optimizer code
45. Training-serving skew is best detected by: A. training accuracy alone B. comparing features/predictions produced by both pipelines on matched examples C. larger models D. more epochs
46. A model card primarily documents: A. GPU temperature B. intended use, evaluation, limitations, and risks C. source code syntax D. only training loss
47. Equalized odds concerns equality across groups of: A. mean predictions B. TPR and FPR C. feature counts D. base rates
48. Demographic parity and perfect calibration may conflict when groups have different: A. sample names B. base rates C. file formats D. learning rates
49. Encrypting data at rest does not by itself prevent: A. unauthorized inference from released predictions B. disk theft C. file corruption D. network latency
50. Before replacing a simple production model with a complex one, the strongest evidence is: A. lower training loss B. reproducible offline gain plus safe online evaluation and monitoring C. more parameters D. a newer library

## Part B — Numerical responses (Questions 51–70, 2 points each)

51. For `y=[1,3]` and predictions `[2,5]`, compute MSE.
52. One gradient step uses `J(θ)=(θ-4)²`, `θ=0`, and `α=0.1`. Find the new `θ`.
53. With standardized orthogonal predictors, ridge gives `β̂ⱼ=zⱼ/(1+λ)`. Find `β̂ⱼ` for `zⱼ=6`, `λ=2`.
54. Compute the lasso soft-threshold result `sign(z)max(|z|-λ,0)` for `z=-3`, `λ=1.2`.
55. Compute `σ(log 3)`.
56. A logistic coefficient is `log 2`. By what factor do the odds change for a one-unit increase?
57. For `y=1` and predicted probability `0.8`, compute binary log-loss to three decimals.
58. With `TP=36, FP=12, FN=4, TN=48`, compute precision and recall.
59. Using Question 58, compute F1 to three decimals.
60. A classifier has TPR `0.8`, FPR `0.1`, prevalence `0.05`, and 10,000 cases. Compute expected TP and FP.
61. Fold accuracies are `[0.70,0.80,0.90,0.80]`. Compute their mean and population standard deviation.
62. In a bootstrap sample of size `n`, the probability a fixed row is omitted approaches what constant as `n→∞`?
63. Parent node: 40 positive, 60 negative. A split produces left `(30+,10-)` and right `(10+,50-)`. Using Gini `1-Σp²`, compute the weighted child impurity.
64. Points `(0,0)` and `(2,2)` form one K-means cluster. Find its centroid and within-cluster sum of squared distances.
65. A covariance matrix is `[[3,1],[1,3]]`. Give its largest eigenvalue and a corresponding unit eigenvector.
66. An SVM has `w=(3,4)`. Compute geometric margin width `2/||w||`.
67. A dense layer has 20 inputs and 8 outputs with biases. How many trainable parameters?
68. A `32×32` image convolved with a `3×3` kernel, stride 1, no padding produces what spatial size?
69. Current positive rate is 0.12 versus training rate 0.08. Compute the relative increase.
70. A production model processes 2 million predictions/day; 0.4% have missing required features. How many affected predictions/day?

## Part C — Python/scikit-learn reasoning (Questions 71–80, 3 points each)

71. Explain the leakage and correct this pattern: `X_scaled=StandardScaler().fit_transform(X); cross_val_score(LogisticRegression(),X_scaled,y,cv=5)`.
72. Why is this invalid for a final estimate, and what split should be used? `GridSearchCV(model,grid,cv=5).fit(X_train,y_train); score=best_model.score(X_test,y_test)` followed by repeated grid changes chosen from `score`.
73. A binary classifier returns probabilities. Write the NumPy expression that predicts positive at threshold `0.30` from `proba`.
74. `confusion_matrix(y_true,y_pred)` returns `[[90,10],[30,70]]` with labels `[0,1]`. Identify TN, FP, FN, and TP.
75. Explain why `cross_val_score(KNeighborsClassifier(), X, y)` may be distorted when features use meters and kilograms, and give a pipeline fix.
76. In scikit-learn logistic regression, increasing `C` usually has what effect on regularization strength and coefficient magnitude?
77. Find the bug: `train_test_split(X,y,test_size=.2,random_state=1); model.fit(X,y); model.score(X_test,y_test)`.
78. A dataset contains repeated measurements per subject. Name the splitter family needed and the argument that must be passed during splitting/evaluation.
79. Why can `accuracy` be a poor GridSearchCV scoring choice for 1% fraud, and name two alternatives reflecting different business goals.
80. A `Pipeline([('scale',StandardScaler()),('model',LogisticRegression())])` is tuned with grid key `C:[.1,1,10]`. Correct the parameter key.

## Part D — Derivations (Questions 81–90, 5 points each)

81. Derive the normal equations for OLS by differentiating `||y-Xβ||²`.
82. Show why Gaussian noise with constant variance makes maximum likelihood estimation of `β` equivalent to minimizing squared error.
83. Derive the gradient of binary logistic negative log-likelihood in matrix form.
84. Show that the logistic negative log-likelihood is convex by analyzing its Hessian.
85. Derive the closed-form ridge estimator for objective `||y-Xβ||²+λ||β||²`.
86. Derive the bias–variance–noise decomposition for squared prediction error at a fixed `x₀`.
87. Prove that the sample mean minimizes the sum of squared distances from scalar observations.
88. Using a Lagrange multiplier, show that the first PCA direction is the leading eigenvector of the covariance matrix.
89. Derive the gradient updates for a one-hidden-unit network `ŷ=v·ReLU(wx)` under loss `(ŷ-y)²`, assuming `wx>0`.
90. Explain mathematically why log-loss penalizes a confident wrong binary prediction without bound as the assigned true-class probability approaches zero.

## Part E — Case analysis (Questions 91–100, 3 points each)

91. A hospital dataset has many visits per patient. Design a leakage-safe validation strategy for predicting readmission.
92. A fraud team values catching fraud at least 15 times more than reviewing a legitimate transaction. Specify how to choose a decision threshold.
93. A churn model has ROC-AUC 0.91 but poor calibration. Explain how it may still rank well and propose a calibration workflow.
94. A house-price model performs much worse for luxury properties. Give two diagnostic checks and two possible remedies.
95. Training score improves with tree depth while validation score peaks at depth 6. Recommend a model-selection procedure and final refit.
96. A text classifier uses vocabulary features fitted on the entire dataset before splitting. Diagnose the problem and redesign the workflow.
97. Offline accuracy is stable, but live performance falls after a product redesign. Give a monitoring and investigation plan.
98. A hiring classifier has similar overall accuracy across groups but very different false-negative rates. State the risk and an appropriate group-aware evaluation.
99. Choose between linear/logistic regression, random forest, and gradient boosting for a small tabular dataset requiring transparent decisions. Justify an initial model and challenger strategy.
100. Outline a safe deployment plan for a new credit-risk model, including validation, rollout, monitoring, and rollback.

---

# Worked Answer Key — stop here until you finish

Difficulty: **AU** = advanced undergraduate; **G** = graduate challenge. Source abbreviations are expanded in the bibliography.

## Questions 1–50

1. **B.** More same-population data primarily reduces estimation variance, not approximation bias. `[AU; ISLP-2]`
2. **C.** Setting the squared-loss gradient to zero gives the full-rank OLS expression. `[AU; CS229-1]`
3. **A.** Rank deficiency makes coefficients non-identifiable; fitted projections can still be unique. `[AU; ISLP-3]`
4. **B.** `E[ε|X]=0` implies `E[β̂|X]=β` when the estimator exists. `[G; PML]`
5. **B.** Rescaling changes curvature and gradient magnitudes, worsening conditioning. `[AU; DL-4]`
6. **A.** A step larger than the stable range can overshoot repeatedly. `[AU; CS229-1]`
7. **B.** Shrinkage stabilizes estimates when correlated predictors make OLS coefficients volatile. `[AU; ISLP-6]`
8. **C.** Stronger shrinkage trades increased bias for lower variance; training error normally rises. `[AU; ISLP-6]`
9. **B.** The L1 corner geometry permits exact zero solutions. `[AU; ESL-3]`
10. **B.** The gap and instability indicate variance, addressed by reduced complexity or regularization. `[AU; ISLP-5]`
11. **C.** Holding other variables fixed, a unit increase changes log-odds by `βⱼ`. `[AU; ISLP-4]`
12. **A.** Separating coefficients can grow without a finite unregularized maximum. `[G; CS229-1]`
13. **B.** `XᵀWX` is positive semidefinite since `Wᵢᵢ=pᵢ(1-pᵢ)≥0`. `[G; CS229-1]`
14. **B.** Lowering the threshold generally catches more positives, accepting more false alarms. `[AU; SK-ME]`
15. **A.** With low prevalence, even a modest FPR can dominate true positives. `[AU; ISLP-4]`
16. **B.** Calibration compares stated probabilities with empirical frequencies. `[AU; SK-ME]`
17. **B.** ROC-AUC measures ranking over thresholds. `[AU; SK-ME]`
18. **B.** The majority-class baseline exposes why raw accuracy is insufficient. `[AU; ISLP-4]`
19. **B.** Repeated test-driven choices overfit the test set. `[AU; ISLP-5]`
20. **B.** Inner folds tune; outer folds estimate the whole selection procedure. `[G; SK-CV]`
21. **B.** Transformation parameters incorporate held-out fold information. `[AU; SK-PIPE]`
22. **C.** Training must precede validation in time. `[AU; SK-CV]`
23. **A.** Subject-level grouping prevents correlated records from appearing on both sides. `[AU; SK-CV]`
24. **B.** Stratification preserves approximate label ratios. `[AU; SK-CV]`
25. **B.** Similar poor scores indicate underfitting rather than a large generalization gap. `[AU; ISLP-2]`
26. **B.** Bootstrap datasets draw `n` rows with replacement. `[AU; ISLP-5]`
27. **B.** Trees maximize impurity reduction, equivalently minimizing weighted child impurity. `[AU; ISLP-8]`
28. **B.** Random feature subsets decorrelate trees beyond bootstrap variation. `[AU; ISLP-8]`
29. **A.** Boosting adds weak learners that target current residual/error structure. `[AU; ISLP-8]`
30. **B.** Large gamma makes influence decay quickly, producing local boundaries. `[AU; ISLP-9]`
31. **A.** `C` penalizes violations relative to a wide margin. `[AU; ISLP-9]`
32. **B.** This is the K-means within-cluster sum-of-squares objective. `[AU; ISLP-12]`
33. **B.** Units directly alter Euclidean distances. `[AU; ISLP-12]`
34. **B.** PCA maximizes variance subject to unit length and orthogonality constraints. `[AU; ESL-14]`
35. **B.** Even without labels, test features influence the learned projection. `[AU; SK-PIPE]`
36. **A.** Averaging chiefly reduces variance. `[AU; ISLP-8]`
37. **B.** ReLU has derivative one on its positive region rather than saturating there. `[AU; DL-6]`
38. **B.** Randomly dropping units regularizes co-adaptation. `[AU; DL-7]`
39. **A.** Softmax supplies a normalized distribution across mutually exclusive classes. `[AU; DL-6]`
40. **B.** Backprop reuses chain-rule computations through the graph. `[AU; DL-6]`
41. **A.** Local receptive fields and shared kernels encode image structure efficiently. `[AU; DL-9]`
42. **B.** Learned dense-vector geometry can represent semantic/syntactic similarity. `[AU; DL-12]`
43. **B.** The mapping being predicted changes, not merely input frequency. `[AU; GOOGLE-ML]`
44. **A.** Covariate shift changes inputs while preserving the conditional relationship by definition. `[G; PML]`
45. **B.** Matched-example comparisons localize discrepancies between pipelines. `[AU; GOOGLE-ML]`
46. **B.** Model cards communicate intended use, performance boundaries, and risks. `[AU; NIST]`
47. **B.** Equalized odds requires equal TPR and FPR conditional on the true label. `[G; PML]`
48. **B.** Different prevalences create known incompatibilities among common fairness criteria. `[G; PML]`
49. **A.** Output access can still expose membership or sensitive attributes. `[G; NIST]`
50. **B.** Deployment requires evidence beyond in-sample fit and a monitored safety path. `[AU; GOOGLE-ML]`

## Questions 51–70

51. Errors are `-1,-2`; **MSE = `(1+4)/2=2.5`**. `[AU; CS229-1]`
52. `J'(θ)=2(θ-4)=-8`; **`θ_new=0-0.1(-8)=0.8`**. `[AU; CS229-1]`
53. **`6/(1+2)=2`**. `[AU; ISLP-6]`
54. **`-max(3-1.2,0)=-1.8`**. `[G; ESL-3]`
55. `e^(-log 3)=1/3`; **`σ(log 3)=3/4=0.75`**. `[AU; CS229-1]`
56. Odds multiply by **`exp(log 2)=2`**. `[AU; ISLP-4]`
57. **`-log(.8)=0.223`**. `[AU; CS229-1]`
58. **Precision `=36/48=.75`; recall `=36/40=.90`**. `[AU; SK-ME]`
59. **`2(.75)(.90)/(.75+.90)=0.818`**. `[AU; SK-ME]`
60. Actual positives `=500`, negatives `=9500`; **TP `=400`, FP `=950`**. `[AU; ISLP-4]`
61. Mean **0.80**; squared deviations average `.005`, so population SD **`√.005≈.071`**. `[AU; ISLP-5]`
62. `(1-1/n)^n→` **`e⁻¹≈0.368`**. `[G; ISLP-5]`
63. Left Gini `=.375`, right `=5/18≈.278`; weighted value **`.4(.375)+.6(.278)=.317`**. `[AU; ISLP-8]`
64. Centroid **`(1,1)`**; each squared distance is 2, so **WCSS=4**. `[AU; ISLP-12]`
65. Eigenvalues are 4 and 2; answer **`λ₁=4`, `v₁=(1,1)/√2`** (sign equivalent accepted). `[AU; ESL-14]`
66. `||w||=5`; width **`2/5=.4`**. `[AU; ISLP-9]`
67. Weights `20×8=160` plus 8 biases: **168**. `[AU; DL-6]`
68. `(32-3)/1+1`: **`30×30`**. `[AU; DL-9]`
69. `(0.12-0.08)/0.08`: **50% relative increase** (4 percentage points absolute). `[AU; GOOGLE-ML]`
70. `2,000,000×.004`: **8,000/day**. `[AU; GOOGLE-ML]`

## Questions 71–80

71. The scaler sees every fold. Use `make_pipeline(StandardScaler(),LogisticRegression())` inside `cross_val_score`. Full credit requires identifying fold leakage and fitting scaling within each training fold. `[AU; SK-PIPE]`
72. Repeated test inspection turns the test set into validation data. Freeze a new untouched test set, or use nested CV for selection and final estimation. `[AU; SK-CV]`
73. **`y_pred = (proba >= 0.30).astype(int)`**. If `proba` has two columns, use `proba[:,1]`. `[AU; SK-ME]`
74. **TN=90, FP=10, FN=30, TP=70**. `[AU; SK-ME]`
75. Distance is dominated by the larger numerical scale. Use `make_pipeline(StandardScaler(),KNeighborsClassifier())`. `[AU; SK-PIPE]`
76. Larger **`C` means weaker regularization**, usually allowing larger coefficient magnitudes. `[AU; SK-LR]`
77. The split outputs were not assigned and the model trained on all data. Assign `X_train,X_test,y_train,y_test=...`, then fit only `X_train,y_train`. `[AU; SK-CV]`
78. Use **GroupKFold/StratifiedGroupKFold** (or a group-aware shuffle splitter) and pass **`groups=subject_id`**. `[AU; SK-CV]`
79. The majority class overwhelms accuracy. Examples: **average precision/PR-AUC** for rare-positive retrieval; **recall** when misses dominate; **precision** when reviews are costly; or a business-cost scorer. Any two justified alternatives earn full credit. `[AU; SK-ME]`
80. Pipeline parameters use step prefixes: **`model__C: [.1,1,10]`**. `[AU; SK-PIPE]`

## Questions 81–90

81. `L=(y-Xβ)ᵀ(y-Xβ)`. Then `∇βL=-2Xᵀy+2XᵀXβ`. Setting it to zero gives **`XᵀXβ=Xᵀy`** and, if invertible, `β̂=(XᵀX)⁻¹Xᵀy`. `[G; CS229-1]`
82. Gaussian likelihood is `∏(2πσ²)^(-1/2)exp[-(yᵢ-xᵢᵀβ)²/(2σ²)]`. Its negative log is a constant plus `(2σ²)⁻¹Σ residual²`; therefore the same `β` minimizes SSE and maximizes likelihood. `[G; CS229-1]`
83. With `p=σ(Xβ)`, each derivative is `(pᵢ-yᵢ)xᵢ`; summing gives **`∇βL=Xᵀ(p-y)`**. `[G; CS229-1]`
84. Differentiating again gives **`H=XᵀWX`**, `Wᵢᵢ=pᵢ(1-pᵢ)≥0`. For any `a`, `aᵀHa=(Xa)ᵀW(Xa)≥0`; hence the loss is convex. `[G; CS229-1]`
85. Gradient: `-2Xᵀ(y-Xβ)+2λβ`. Setting to zero yields **`(XᵀX+λI)β=Xᵀy`**, hence `β̂=(XᵀX+λI)⁻¹Xᵀy`; omit the intercept row/column from the penalty when required. `[G; ISLP-6]`
86. Write `y₀=f(x₀)+ε` and add/subtract `E_D[ f̂(x₀)]`. Taking expectations makes the cross terms zero, producing **`Bias[f̂(x₀)]² + Var[f̂(x₀)] + Var(ε)`**. `[G; ESL-2]`
87. For `g(c)=Σ(xᵢ-c)²`, `g'(c)=2n(c-x̄)` and `g''(c)=2n>0`; the unique minimizer is **`c=x̄`**. `[AU; ISLP-12]`
88. Maximize `vᵀSv` subject to `vᵀv=1`. `ℒ=vᵀSv-λ(vᵀv-1)` gives `Sv=λv`; the objective equals `λ`, so its maximum uses the eigenvector with largest eigenvalue. `[G; ESL-14]`
89. Since `wx>0`, `h=wx`, `ŷ=vwx`, and `L=(vwx-y)²`. Thus **`∂L/∂v=2(vwx-y)wx`** and **`∂L/∂w=2(vwx-y)vx`**; subtract learning-rate multiples. `[G; DL-6]`
90. For true label 1, loss is `-log p`; for label 0, `-log(1-p)`. As the probability assigned to the true class tends to `0⁺`, **`-log(q)→∞`**, so confident errors are unboundedly penalized. `[AU; PML]`

## Questions 91–100

91. Split by patient, never visit; use group-aware CV and, if deployment is prospective, an outer chronological holdout. Fit imputation and preprocessing inside folds. Report uncertainty and patient-relevant metrics. `[AU; SK-CV]`
92. With calibrated probabilities and only the stated costs, the theoretical threshold is **`1/(15+1)=0.0625`**. More generally, choose the validation-set threshold minimizing `15·FN+1·FP` subject to review capacity, then confirm it on untouched data. `[AU; SK-ME]`
93. AUC depends on ordering, not probability scale. Fit the base model on training data, fit Platt or isotonic calibration on separate/CV predictions, and evaluate calibration curve, Brier/log-loss, and AUC on untouched test data. `[G; SK-ME]`
94. Diagnostics: residuals versus fitted/price, segment-specific error, sparse coverage, influential points, and transformation checks. Remedies include log-price/robust loss, nonlinear features or trees, weighted sampling/loss, and more representative luxury data. Any two justified checks and remedies earn full credit. `[AU; ISLP-3]`
95. Select depth using CV entirely within training data, preferably with pruning/other regularization. Choose depth 6 or a one-standard-error simpler model, then refit that fixed choice on all development data and evaluate once on test. `[AU; ISLP-8]`
96. The vocabulary learned test-set occurrence information. Split first; place vectorization and classifier in one pipeline so vocabulary/IDF are fitted within each training fold, then perform one final test evaluation. `[AU; SK-PIPE]`
97. Monitor input/schema drift, missingness, prediction distribution, latency, and delayed outcome metrics. Compare pre/post-redesign cohorts, reproduce training-versus-serving features, check feedback loops, shadow a fix, and retain rollback. `[AU; GOOGLE-ML]`
98. Unequal FNR means qualified members of some groups are rejected more often despite similar aggregate accuracy. Report group confusion matrices, TPR/FNR and FPR with uncertainty; assess equal opportunity/equalized odds and contextual harms. `[G; NIST]`
99. Begin with regularized linear/logistic regression for transparency, calibration, and a defensible baseline. Compare forest and boosting as challengers under nested/group/time-aware validation; retain the simplest model meeting discrimination, calibration, stability, and explanation requirements. `[AU; ISLP-8]`
100. Lock data and leakage-safe validation; test discrimination, calibration, subgroup performance, stress cases, privacy, and security. Use approval/versioning, shadow then canary rollout, actionable drift/performance/skew alerts, audit logs, champion–challenger comparison, and an immediate versioned rollback path. `[AU; GOOGLE-ML; NIST]`

## Scoring and diagnostic guide

- **180–200 (90–100%): Excellent.** Ready for deeper learning theory or applied projects.
- **150–179 (75–89.5%): Strong.** Review the weak topic and question type indicated by your errors.
- **120–149 (60–74.5%): Developing.** Revisit core derivations, validation design, and metrics.
- **Below 120:** Rebuild linear/logistic foundations before attempting the graduate items again.

For Questions 81–90, award 1 point for the setup, 2 for correct intermediate mathematics, 1 for the conclusion, and 1 for assumptions/conditions. For Questions 91–100, award one point each for diagnosis, proposed action, and validation or risk control.

## Reference map

- **CS229-1:** Stanford, [CS229 notes: linear and logistic regression](https://cs229.stanford.edu/notes-spring2019/cs229-notes1.pdf)
- **ISLP:** James et al., [An Introduction to Statistical Learning](https://www.statlearning.com/): chapters 2–6, 8–9, and 12 as tagged
- **ESL:** Hastie, Tibshirani, and Friedman, [The Elements of Statistical Learning](https://hastie.su.domains/ElemStatLearn/main.html): chapters 2–3 and 14 as tagged
- **PML:** Murphy, [Probabilistic Machine Learning: An Introduction](https://probml.github.io/pml-book/book1.html)
- **DL:** Goodfellow, Bengio, and Courville, [Deep Learning](https://www.deeplearningbook.org/contents/TOC.html): chapters 4, 6–7, 9, and 12 as tagged
- **SK-CV / SK-ME:** scikit-learn, [model selection and evaluation](https://scikit-learn.org/stable/model_selection.html)
- **SK-PIPE:** scikit-learn, [Pipeline documentation](https://scikit-learn.org/stable/modules/generated/sklearn.pipeline.Pipeline.html)
- **SK-LR:** scikit-learn, [LogisticRegression documentation](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html)
- **GOOGLE-ML:** Google, [Rules of Machine Learning](https://developers.google.com/machine-learning/guides/rules-of-ml/)
- **NIST:** NIST, [AI Risk Management Framework 1.0](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10)

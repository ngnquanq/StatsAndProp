# Machine Learning — Hsuan-Tien Lin
**Instructor:** Hsuan-Tien Lin (co-author of *Learning from Data*)
**Credits:** 3 | **Grading:** 70% homework, 30% project
**Course page:** https://www.csie.ntu.edu.tw/~htlin/course/ml24fall/

This is the theoretical ML foundation. Every serious ML student at NTU takes this. It covers the *why* behind ML — why models generalize, what makes learning possible, what the fundamental limits are.

---

## Lecture files (all downloaded)

| File | Topic |
|---|---|
| lecture00_course_overview.pdf | Course overview and logistics |
| lecture01_handout.pdf | Introduction — what is learning? The learning problem |
| lecture02_handout.pdf | Feasibility of learning — Hoeffding inequality |
| lecture03_handout.pdf | VC dimension — measuring model complexity |
| lecture04_handout.pdf | Training vs. testing — generalization bounds |
| lecture05_handout.pdf | Linear regression |
| lecture06_handout.pdf | Logistic regression, gradient descent |
| lecture07_handout.pdf | Linear models for classification |
| lecture08_handout.pdf | Nonlinear transformation |
| lecture09_handout.pdf | Overfitting, noise, and regularization |
| lecture10_handout.pdf | Validation |
| lecture11_handout.pdf | Support Vector Machines (hard margin) |
| lecture12_handout.pdf | Kernel SVM (soft margin, RBF kernel) |
| lecture13_handout.pdf | Ensemble methods — bagging, boosting, AdaBoost |
| lecture14_handout.pdf | Decision trees, random forests |
| lecture15_handout.pdf | Neural networks and deep learning overview |

---

## Textbook

*Learning from Data* — Yaser Abu-Mostafa, Magdon-Ismail, Hsuan-Tien Lin
- Free companion site (lecture videos + slides): https://work.caltech.edu/telecourse.html
- Free online version: https://amlbook.com/
- `lfd_lecture01_intro.pdf` and `lfd_lecture02_feasibility.pdf` are in this folder (Caltech versions)

---

## Reading priority for your direction

You already have strong stats foundations. Focus on:
1. **lecture02** — Hoeffding inequality: this is the basis for randomized smoothing proofs
2. **lecture03** — VC dimension: underpins certified robustness theory
3. **lecture04** — generalization bounds: connects to PAC-Bayes and privacy
4. **lecture11–12** — SVM: important for understanding kernel methods used in some privacy attacks
5. **lecture15** — neural networks: make sure you understand backprop before lab starts

---

## Homework structure

70% of the grade is problem sets. Expect:
- Mathematical derivations (prove the Hoeffding bound for a given model class)
- Coding experiments (implement logistic regression from scratch, compare to sklearn)
- Short analysis questions (explain why overfitting worsens with noise)

Do every problem set seriously — Lin's graders are strict and the theory you learn here is tested in Chen's SPML course.

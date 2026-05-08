# Thí nghiệm phát hiện điểm ngoại lai

Mã nguồn tái lập cho báo cáo `outlier_detection.tex`. Sinh 3 dataset mô phỏng,
chạy 11 phương pháp phát hiện ngoại lai và xuất hình + bảng metric vào
`figs/` và `results_table.tex`.

## Yêu cầu

- Conda (Anaconda/Miniconda).
- Các gói: `numpy`, `scipy`, `scikit-learn`, `matplotlib`, `pandas` — đã
  sẵn trong môi trường `base` của Anaconda. Nếu chưa có, tạo môi trường
  riêng từ `environment.yml`:

```bash
conda env create -f environment.yml
conda activate outlier-detection
```

## Chạy

```bash
cd code
python run_all.py
```

Đầu ra:

- `code/data.npz` — dữ liệu mô phỏng (seed 42).
- `figs/*.pdf` — 13 hình minh họa.
- `results_table.tex` — bảng metric tổng hợp (booktabs).
- Stdout: tóm tắt Precision/Recall/F1/AUC cho từng phương pháp.

## Tái lập

Mọi nguồn ngẫu nhiên đều được seed (`np.random.seed(42)`,
`random_state=42`). Chạy lại `run_all.py` cho kết quả giống hệt.

## Cấu trúc

```
code/
├── environment.yml     # đặc tả môi trường conda
├── data_gen.py         # sinh 3 dataset
├── methods/
│   ├── univariate.py   # Z-score, Modified Z, IQR, Grubbs ESD
│   ├── multivariate.py # Mahalanobis, PCA T²/Q
│   ├── density.py      # DBSCAN, LOF
│   └── ml.py           # IsolationForest, OC-SVM, Autoencoder MLP
├── evaluate.py         # P/R/F1/AUC + sinh results_table.tex
├── plotting.py         # hình minh họa
└── run_all.py          # entry point
```

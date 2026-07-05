# NomNaOCR Integration Notes

This directory is intentionally kept lightweight. The full upstream repository
and model weights are large external artifacts and should stay under
`models/NomNaOCR/`, which is git-ignored.

Expected runtime layout:

```text
models/NomNaOCR/
  source/                 # clone of https://github.com/ds4v/NomNaOCR
  All.txt                 # NomNaOCR transcript file for vocabulary metadata
  weights/
    Fine-tuning/finetune_SC-CNNxTransformer_cnn.h5
    Fine-tuning/finetune_SC-CNNxTransformer_enc.h5
    Fine-tuning/finetune_SC-CNNxTransformer_dec.h5
    NomNaOCR/NomNaOCR_CRNNxCTC.h5  # optional CRNN candidate
```

`nomnaocr_ocr.py` can also read the source checkout from `NOMNAOCR_REPO`.

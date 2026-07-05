"""NomNaOCR candidate recognizer for the HVH benchmark pipeline.

NomNaOCR is treated as another candidate model. It reuses the line boxes from
the PaddleOCRv5 local candidate cache (page_NNN.local.json) and only runs the
NomNaOCR text recognizer on those crops, so CER comparisons against the CLC/API
benchmark use the same line ordering as the other local candidates.
"""

from __future__ import annotations

import json
import os
import re
import sys
from collections import Counter
from string import printable
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).parent
CACHE_DIR = HERE / "cache"
ASSET_DIR = Path(os.environ.get("NOMNAOCR_ASSET_DIR", HERE / "models" / "NomNaOCR"))
SOURCE_DIR = ASSET_DIR / "source"
WEIGHTS_DIR = ASSET_DIR / "weights"

ORIENTATIONS = ("vertical", "rot_ccw", "rot_cw")
MODELS = ("sc_transformer", "crnn_ctc")
HEIGHT, WIDTH = 432, 48
PADDING_CHAR = "[PAD]"
START_CHAR = "[START]"
END_CHAR = "[END]"


class NomNaOCRError(RuntimeError):
    pass


def _crop(page, box, orientation):
    crop = page.crop(tuple(box))
    if orientation == "rot_ccw":
        crop = crop.rotate(90, expand=True)
    elif orientation == "rot_cw":
        crop = crop.rotate(-90, expand=True)
    return crop


def _text_recognition_dir():
    override = os.environ.get("NOMNAOCR_REPO")
    candidates = []
    if override:
        candidates.append(Path(override))
    candidates.extend([SOURCE_DIR, HERE / "third_party" / "nomnaocr"])

    for root in candidates:
        if (root / "Text recognition").is_dir():
            return root / "Text recognition"
        if (root / "loader.py").is_file() and (root / "layers.py").is_file():
            return root
    raise NomNaOCRError(
        "NomNaOCR source not found. Clone https://github.com/ds4v/NomNaOCR to "
        f"{SOURCE_DIR} or set NOMNAOCR_REPO to the checkout path."
    )


def _add_upstream_source():
    src = _text_recognition_dir()
    src_s = str(src)
    if src_s not in sys.path:
        sys.path.insert(0, src_s)
    return src



def _is_clean_nom_text(text):
    not_nom_chars = r"\sáàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệóòỏõọôốồổỗộơớờởỡợíìỉĩịúùủũụưứừửữựýỳỷỹỵđ"
    pattern = re.compile(f"[{not_nom_chars}{re.escape(printable)}]")
    return not bool(re.search(pattern, text.lower()))

def _read_transcripts(path):
    labels = []
    with path.open(encoding="utf-8") as fh:
        for line in fh:
            parts = line.rstrip("\n").split("\t", 1)
            if len(parts) == 2 and parts[1].strip():
                text = parts[1].strip().lower()
                if _is_clean_nom_text(text):
                    labels.append(text)
    if not labels:
        raise NomNaOCRError(f"{path} did not contain any transcript labels")
    counter = Counter("".join(labels))
    return list(dict(counter.most_common())), max(len(label) for label in labels)


def _load_vocab():
    vocab_json = ASSET_DIR / "vocab.json"
    if vocab_json.exists():
        data = json.loads(vocab_json.read_text(encoding="utf-8"))
        vocab = data.get("vocab") or data.get("vocabulary")
        max_length = data.get("max_length") or data.get("max_label_length")
        if isinstance(vocab, dict):
            vocab = list(vocab)
        if vocab and max_length:
            return list(vocab), int(max_length)
        raise NomNaOCRError(f"{vocab_json} must contain vocab and max_length")

    for name in ("All.txt", "all.txt", "transcripts.txt"):
        path = ASSET_DIR / name
        if path.exists():
            return _read_transcripts(path)

    raise NomNaOCRError(
        "NomNaOCR vocabulary metadata missing. Put All.txt from the NomNaOCR "
        "dataset or vocab.json with {'vocab': [...], 'max_length': N} in "
        f"{ASSET_DIR}."
    )


def _first_existing(paths, label):
    for path in paths:
        if path.exists():
            return path
    formatted = "\n    ".join(str(p) for p in paths)
    raise NomNaOCRError(f"NomNaOCR {label} weights not found. Tried:\n    {formatted}")


def _vocab_size(lookup):
    if hasattr(lookup, "vocabulary_size"):
        return lookup.vocabulary_size()
    return lookup.vocab_size()


class _InferenceDataHandler:
    def __init__(self, vocabulary, max_label_length, with_seq_tokens):
        import tensorflow as tf

        self.tf = tf
        self.img_size = (HEIGHT, WIDTH)
        self.padding_char = PADDING_CHAR
        self.start_char = START_CHAR if with_seq_tokens else ""
        self.end_char = END_CHAR if with_seq_tokens else ""

        vocabulary = list(vocabulary)
        if with_seq_tokens:
            vocabulary += [START_CHAR, END_CHAR]
        self.char2num = tf.keras.layers.StringLookup(vocabulary=vocabulary, mask_token=PADDING_CHAR)
        self.num2char = tf.keras.layers.StringLookup(
            vocabulary=self.char2num.get_vocabulary(),
            mask_token=PADDING_CHAR,
            invert=True,
        )

        self.max_length = int(max_label_length) + (2 if with_seq_tokens else 0)
        self.start_token = self.char2num(START_CHAR) if with_seq_tokens else None
        self.end_token = self.char2num(END_CHAR) if with_seq_tokens else None
        mask_idxs = [0, 1]
        if with_seq_tokens:
            mask_idxs.append(self.start_token)
        token_mask = np.zeros([_vocab_size(self.char2num)], dtype=bool)
        token_mask[np.array(mask_idxs)] = True
        self.token_mask = token_mask

    def preprocess_crop(self, crop):
        tf = self.tf
        image = np.asarray(crop.convert("RGB"))
        image = tf.convert_to_tensor(image, dtype=tf.float32)
        image = tf.image.resize(image, size=self.img_size, preserve_aspect_ratio=True)
        pad_height = HEIGHT - tf.shape(image)[0]
        pad_width = WIDTH - tf.shape(image)[1]
        image = tf.pad(image, [[0, pad_height], [0, pad_width], [0, 0]], constant_values=255)
        return image / 255.0

    def tokens2texts(self, batch_tokens, use_ctc_decode=False):
        tf = self.tf
        if use_ctc_decode:
            decoded, _ = tf.keras.backend.ctc_decode(
                batch_tokens,
                input_length=np.full((batch_tokens.shape[0],), batch_tokens.shape[1]),
                greedy=True,
            )
            batch_tokens = decoded[0]

        texts = []
        for tokens in batch_tokens:
            tokens = tf.reshape(tokens, [-1])
            keep = tf.logical_and(tokens != 0, tokens != -1)
            text = tf.strings.reduce_join(self.num2char(tf.boolean_mask(tokens, keep)))
            value = text.numpy().decode("utf-8")
            value = value.replace(self.start_char, "").replace(self.end_char, "")
            texts.append(value)
        return texts


def _reshape_features(tf, last_cnn_layer, dim_to_keep=-1, name="cnn_features"):
    _, height, width, channel = last_cnn_layer.shape
    if dim_to_keep == 1:
        target_shape = (height, width * channel)
    elif dim_to_keep == 2:
        target_shape = (width, height * channel)
    elif dim_to_keep in (3, -1):
        target_shape = (height * width, channel)
    else:
        raise ValueError("Invalid dim_to_keep value")
    return tf.keras.layers.Reshape(target_shape=target_shape, name=name)(last_cnn_layer)


def _custom_cnn_model(tf, custom_cnn):
    image_input = tf.keras.layers.Input(shape=(HEIGHT, WIDTH, 3), dtype="float32", name="image")
    conv_blocks_config = {
        "block1": {"num_conv": 1, "filters": 64, "pool_size": (2, 2)},
        "block2": {"num_conv": 1, "filters": 128, "pool_size": (2, 2)},
        "block3": {"num_conv": 2, "filters": 256, "pool_size": (2, 2)},
        "block4": {"num_conv": 2, "filters": 512, "pool_size": (2, 2)},
        "block5": {"num_conv": 2, "filters": 512, "pool_size": None},
    }
    x = custom_cnn(conv_blocks_config, image_input)
    feature_maps = _reshape_features(tf, x, dim_to_keep=1)
    return tf.keras.Model(inputs=image_input, outputs=feature_maps, name="CNN_model")


def _transformer_encoder_block(
    tf, TransformerEmbedding, TransformerEncoderLayer, receptive_size, num_layers,
    num_heads, embedding_dim, feed_forward_units, dropout_rate, use_skip_connection=False,
    name="TransformerEncoderBlock"
):
    features_maps = tf.keras.layers.Input(shape=(receptive_size, embedding_dim), dtype="float32", name="cnn_features")
    x = TransformerEmbedding(embedding_dim, receptive_size, name="PositionalEncoding")(features_maps)
    if dropout_rate > 0:
        x = tf.keras.layers.Dropout(dropout_rate, name="embedding_dropout")(x)
    for i in range(num_layers):
        x = TransformerEncoderLayer(
            num_heads=num_heads,
            embedding_dim=embedding_dim,
            feed_forward_units=feed_forward_units,
            dropout_rate=dropout_rate,
            name=f"Encoder{i + 1}",
        )(x, training=False)
    if use_skip_connection:
        x = tf.keras.layers.Add(name="skip_connection")([features_maps, x])
    return tf.keras.Model(inputs=features_maps, outputs=x, name=name)


def _transformer_decoder_block(
    tf, TransformerEmbedding, TransformerDecoderLayer, enc_shape, seq_length, vocab_size,
    num_layers, num_heads, embedding_dim, feed_forward_units, dropout_rate,
    name="TransformerDecoderBlock"
):
    enc_output = tf.keras.layers.Input(shape=enc_shape, dtype="float32", name="encoder_output")
    dec_seq_input = tf.keras.layers.Input(shape=(seq_length,), dtype="int64", name="decoder_sequence")
    attention_weights = {}
    x = TransformerEmbedding(embedding_dim, seq_length, vocab_size, name="TokEmbAndPosEncode")(dec_seq_input)
    if dropout_rate > 0:
        x = tf.keras.layers.Dropout(dropout_rate, name="embedding_dropout")(x)
    for i in range(num_layers):
        layer_name = f"Decoder{i + 1}"
        x, block1, block2 = TransformerDecoderLayer(
            num_heads=num_heads,
            embedding_dim=embedding_dim,
            feed_forward_units=feed_forward_units,
            dropout_rate=dropout_rate,
            name=layer_name,
        )(x, enc_output, training=False, mask=(dec_seq_input != 0))
        attention_weights[f"{layer_name}_block1"] = block1
        attention_weights[f"{layer_name}_block2"] = block2
    y_pred = tf.keras.layers.Dense(vocab_size, name="prediction")(x)
    return tf.keras.Model(inputs=[dec_seq_input, enc_output], outputs=[y_pred, attention_weights], name=name)


class NomNaOCR:
    cache_suffix = "nomnaocr"

    def __init__(self, model="sc_transformer", orientation="vertical", batch_size=32):
        if model not in MODELS:
            raise NomNaOCRError(f"model must be one of {MODELS}, not {model!r}")
        if orientation not in ORIENTATIONS:
            raise NomNaOCRError(f"orientation must be one of {ORIENTATIONS}, not {orientation!r}")

        self.model_name = model
        self.orientation = orientation
        self.batch_size = batch_size

        _add_upstream_source()
        try:
            import tensorflow as tf
        except ImportError as err:
            raise NomNaOCRError("NomNaOCR needs TensorFlow; use the py310-ml conda env") from err

        self.tf = tf
        vocab, max_label_length = _load_vocab()
        self.data_handler = _InferenceDataHandler(
            vocab,
            max_label_length,
            with_seq_tokens=(model == "sc_transformer"),
        )
        self.model = self._load_model()

    def _load_model(self):
        if self.model_name == "crnn_ctc":
            return self._load_crnn()
        return self._load_sc_transformer()

    def _load_crnn(self):
        tf = self.tf
        from layers import custom_cnn

        image_input = tf.keras.layers.Input(shape=(HEIGHT, WIDTH, 3), dtype="float32", name="image")
        conv_blocks_config = {
            "block1": {"num_conv": 1, "filters": 64, "pool_size": (2, 2)},
            "block2": {"num_conv": 1, "filters": 128, "pool_size": (2, 2)},
            "block3": {"num_conv": 2, "filters": 256, "pool_size": (2, 2)},
            "block4": {"num_conv": 2, "filters": 512, "pool_size": (2, 2)},
            "block5": {"num_conv": 2, "filters": 512, "pool_size": None},
        }
        x = custom_cnn(conv_blocks_config, image_input)
        feature_maps = _reshape_features(tf, x, dim_to_keep=1, name="rnn_input")
        x = tf.keras.layers.Bidirectional(tf.keras.layers.GRU(256, return_sequences=True), name="bigru1")(feature_maps)
        x = tf.keras.layers.Bidirectional(tf.keras.layers.GRU(256, return_sequences=True), name="bigru2")(x)
        y_pred = tf.keras.layers.Dense(
            units=_vocab_size(self.data_handler.char2num) + 1,
            activation="softmax",
            name="rnn_output",
        )(x)
        model = tf.keras.Model(inputs=image_input, outputs=y_pred, name="CRNN")
        weights = _first_existing(
            [
                WEIGHTS_DIR / "NomNaOCR" / "NomNaOCR_CRNNxCTC.h5",
                WEIGHTS_DIR / "NomNaOCR_CRNNxCTC.h5",
                WEIGHTS_DIR / "CRNNxCTC.h5",
                WEIGHTS_DIR / "Fine-tuning" / "finetune_CRNNxCTC.h5",
                WEIGHTS_DIR / "finetune_CRNNxCTC.h5",
                ASSET_DIR / "NomNaOCR_CRNNxCTC.h5",
            ],
            "CRNNxCTC",
        )
        model.load_weights(str(weights))
        return model

    def _load_sc_transformer(self):
        tf = self.tf
        from layers import custom_cnn
        from transformer import TransformerDecoderLayer, TransformerEmbedding, TransformerEncoderLayer, TransformerOCR

        cnn_model = _custom_cnn_model(tf, custom_cnn)
        encoder = _transformer_encoder_block(tf, TransformerEmbedding, TransformerEncoderLayer,
            receptive_size=cnn_model.output_shape[-2],
            num_layers=2,
            num_heads=1,
            embedding_dim=512,
            feed_forward_units=512,
            dropout_rate=0.1,
            use_skip_connection=True,
        )
        decoder = _transformer_decoder_block(tf, TransformerEmbedding, TransformerDecoderLayer,
            enc_shape=encoder.output_shape[1:],
            seq_length=self.data_handler.max_length - 1,
            vocab_size=_vocab_size(self.data_handler.char2num),
            num_layers=2,
            num_heads=1,
            embedding_dim=512,
            feed_forward_units=512,
            dropout_rate=0.1,
        )
        for component, candidates in {
            "cnn": [
                WEIGHTS_DIR / "Fine-tuning" / "finetune_SC-CNNxTransformer_cnn.h5",
                WEIGHTS_DIR / "finetune_SC-CNNxTransformer_cnn.h5",
                WEIGHTS_DIR / "NomNaOCR" / "NomNaOCR_SC-CNNxTransformer_cnn.h5",
                WEIGHTS_DIR / "NomNaOCR_SC-CNNxTransformer_cnn.h5",
            ],
            "encoder": [
                WEIGHTS_DIR / "Fine-tuning" / "finetune_SC-CNNxTransformer_enc.h5",
                WEIGHTS_DIR / "finetune_SC-CNNxTransformer_enc.h5",
                WEIGHTS_DIR / "NomNaOCR" / "NomNaOCR_SC-CNNxTransformer_enc.h5",
                WEIGHTS_DIR / "NomNaOCR_SC-CNNxTransformer_enc.h5",
            ],
            "decoder": [
                WEIGHTS_DIR / "Fine-tuning" / "finetune_SC-CNNxTransformer_dec.h5",
                WEIGHTS_DIR / "finetune_SC-CNNxTransformer_dec.h5",
                WEIGHTS_DIR / "NomNaOCR" / "NomNaOCR_SC-CNNxTransformer_dec.h5",
                WEIGHTS_DIR / "NomNaOCR_SC-CNNxTransformer_dec.h5",
            ],
        }.items():
            weights = _first_existing(candidates, f"SC-CNNxTransformer {component}")
            {"cnn": cnn_model, "encoder": encoder, "decoder": decoder}[component].load_weights(str(weights))
        return TransformerOCR(cnn_model, encoder, decoder, self.data_handler)

    def _boxes_for_image(self, image_path):
        unit_code = image_path.parent.name
        local_file = CACHE_DIR / unit_code / f"{image_path.stem}.local.json"
        if not local_file.exists():
            raise NomNaOCRError(
                f"missing detector boxes in {local_file}; run "
                f"conda run -n hvh python run_pipeline.py --engine local {unit_code}"
            )
        data = json.loads(local_file.read_text(encoding="utf-8"))
        boxes = data.get("boxes")
        if not boxes:
            raise NomNaOCRError(f"{local_file} has no boxes")
        return boxes

    def _recognize(self, crops):
        tf = self.tf
        lines, scores = [], []
        for i in range(0, len(crops), self.batch_size):
            batch = crops[i:i + self.batch_size]
            images = tf.stack([self.data_handler.preprocess_crop(crop) for crop in batch])
            pred = self.model.predict(images) if self.model_name == "sc_transformer" else self.model.predict(images, verbose=0)
            use_ctc = self.model_name == "crnn_ctc"
            if isinstance(pred, tuple):
                pred = pred[0]
            lines.extend(text.replace(" ", "") for text in self.data_handler.tokens2texts(pred, use_ctc_decode=use_ctc))
            scores.extend([None] * len(batch))
        return lines, scores

    def ocr_page(self, image_path):
        image_path = Path(image_path)
        boxes = self._boxes_for_image(image_path)
        page = Image.open(image_path).convert("RGB")
        crops = [_crop(page, box, self.orientation) for box in boxes]
        lines, scores = self._recognize(crops)
        return {
            "image": str(image_path),
            "source": "nomnaocr",
            "model": self.model_name,
            "orientation": self.orientation,
            "lines": lines,
            "scores": scores,
            "boxes": boxes,
        }


def recognize_page_with_boxes(engine, image_path, boxes):
    page = Image.open(image_path).convert("RGB")
    crops = [_crop(page, box, engine.orientation) for box in boxes]
    lines, scores = engine._recognize(crops)
    return {
        "image": str(image_path),
        "source": "nomnaocr",
        "model": engine.model_name,
        "orientation": engine.orientation,
        "lines": lines,
        "scores": scores,
        "boxes": boxes,
    }

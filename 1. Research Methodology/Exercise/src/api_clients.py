import json
import hashlib
import re
import time
from pathlib import Path

from google import genai
from google.genai import types

from .utils import load_env, retry_with_backoff, logger

CACHE_DIR = Path(__file__).parent.parent / "data" / "results" / ".cache"

_client = None


def _get_client():
    global _client
    if _client is None:
        api_key = load_env()
        _client = genai.Client(api_key=api_key)
    return _client


def _cache_path(model: str, prompt: str) -> Path:
    key = hashlib.sha256(f"{model}::{prompt}".encode()).hexdigest()[:16]
    return CACHE_DIR / f"{key}.json"


def _load_cache(model: str, prompt: str) -> str | None:
    path = _cache_path(model, prompt)
    if path.exists():
        data = json.loads(path.read_text())
        logger.info(f"Cache hit for {model} (hash={path.stem})")
        return data["response"]
    return None


def _save_cache(model: str, prompt: str, response: str):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = _cache_path(model, prompt)
    path.write_text(json.dumps({"model": model, "prompt": prompt, "response": response}))


@retry_with_backoff(max_retries=5, base_delay=10.0, backoff_factor=2.0)
def _raw_generate(model_name: str, prompt: str, system_instruction: str | None = None) -> str:
    client = _get_client()
    config = None
    if system_instruction:
        config = types.GenerateContentConfig(system_instruction=system_instruction)
    response = client.models.generate_content(
        model=model_name,
        contents=prompt,
        config=config,
    )
    return response.text


_call_count = [0]


def call_gemini(
    prompt: str,
    model: str = "gemini-2.5-flash-lite",
    system_instruction: str | None = None,
    delay: float = 5.0,
    use_cache: bool = True,
) -> str:
    """Call Gemini API with caching, rate limiting, and retry."""
    if use_cache:
        cached = _load_cache(model, prompt)
        if cached is not None:
            return cached

    _call_count[0] += 1
    if _call_count[0] > 1:
        logger.debug(f"Rate limit delay: {delay}s")
        time.sleep(delay)

    logger.info(f"Calling {model} (call #{_call_count[0]})")
    response = _raw_generate(model, prompt, system_instruction)

    if use_cache:
        _save_cache(model, prompt, response)

    return response

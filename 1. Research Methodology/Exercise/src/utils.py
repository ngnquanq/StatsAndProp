import os
import time
import logging
import functools
from dotenv import load_dotenv


def setup_logging(level=logging.INFO):
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    return logging.getLogger(__name__)


logger = setup_logging()


def load_env():
    load_dotenv()
    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        raise ValueError("GOOGLE_API_KEY not found in environment. Check your .env file.")
    return api_key


def rate_limiter(delay_seconds=5):
    """Decorator that enforces a minimum delay between successive calls."""
    def decorator(func):
        last_call_time = [0.0]

        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_call_time[0]
            if elapsed < delay_seconds:
                sleep_time = delay_seconds - elapsed
                logger.debug(f"Rate limiter: sleeping {sleep_time:.1f}s")
                time.sleep(sleep_time)
            last_call_time[0] = time.time()
            return func(*args, **kwargs)

        return wrapper
    return decorator


def retry_with_backoff(max_retries=3, base_delay=2.0, backoff_factor=2.0):
    """Decorator that retries on exception with exponential backoff."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_retries:
                        delay = base_delay * (backoff_factor ** attempt)
                        logger.warning(
                            f"Attempt {attempt + 1}/{max_retries + 1} failed: {e}. "
                            f"Retrying in {delay:.1f}s..."
                        )
                        time.sleep(delay)
                    else:
                        logger.error(f"All {max_retries + 1} attempts failed: {e}")
            raise last_exception

        return wrapper
    return decorator

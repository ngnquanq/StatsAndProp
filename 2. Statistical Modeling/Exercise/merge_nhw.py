#!/usr/bin/env python3
"""
merge_nhw.py — Deterministic merge of nhw.tex into sections/ directory.

Extracts:
  - Section 1 (Overview)        → sections/sec0_overview/01_overview.tex
  - Section 2 (Homoscedasticity) → sections/sec3_homoscedasticity/*.tex

Also:
  - Maps citation keys to match references.bib
  - Adds missing bibliography entries to references.bib
  - Backs up all overwritten files
"""

import os
import shutil
import re
from datetime import datetime

# ─── Configuration ──────────────────────────────────────────────────────────────

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
NHW_FILE = os.path.join(BASE_DIR, "nhw.tex")
SECTIONS_DIR = os.path.join(BASE_DIR, "sections")
BACKUP_DIR = os.path.join(BASE_DIR, "_backup_before_merge")
REFERENCES_BIB = os.path.join(BASE_DIR, "references.bib")

# Citation key mapping: nhw.tex key → references.bib key
CITATION_MAP = {
    r"\cite{weisberg2014}": r"\cite{weisberg2014applied}",
    r"\cite{rencher2008}":  r"\cite{rencher2008linear}",
    # These keys already match in references.bib:
    # galton1886, james2013, faraway2016, dobson2018, breusch1979,
    # koenker1981, huber1967, white1980, mackinnon1985, maddala2001,
    # sheather2009, wooldridge2015
}

# Missing bib entries to add
MISSING_BIB_ENTRIES = r"""
@article{galton1886,
  author  = {Galton, Francis},
  title   = {Regression Towards Mediocrity in Hereditary Stature},
  journal = {The Journal of the Anthropological Institute},
  volume  = {15},
  pages   = {246--263},
  year    = {1886}
}

@book{james2013,
  author    = {James, Gareth and Witten, Daniela and Hastie, Trevor and Tibshirani, Robert},
  title     = {An Introduction to Statistical Learning},
  publisher = {Springer},
  year      = {2013}
}

@book{maddala2001,
  author    = {Maddala, G. S.},
  title     = {Introduction to Econometrics},
  edition   = {3},
  publisher = {Wiley},
  year      = {2001}
}

@book{sheather2009,
  author    = {Sheather, Simon},
  title     = {A Modern Approach to Regression with R},
  publisher = {Springer},
  year      = {2009}
}

@book{wooldridge2015,
  author    = {Wooldridge, Jeffrey M.},
  title     = {Introductory Econometrics: A Modern Approach},
  edition   = {6},
  publisher = {Cengage Learning},
  year      = {2015}
}
"""

# ─── Helpers ────────────────────────────────────────────────────────────────────

def read_file(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def read_lines(path: str) -> list[str]:
    with open(path, "r", encoding="utf-8") as f:
        return f.readlines()


def write_file(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  ✓ Wrote {path}")


def backup_file(src: str) -> None:
    if not os.path.exists(src):
        return
    rel = os.path.relpath(src, BASE_DIR)
    dst = os.path.join(BACKUP_DIR, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)
    print(f"  ⟳ Backed up {rel}")


def apply_citation_map(text: str) -> str:
    """Replace citation keys from nhw.tex to match references.bib."""
    for old, new in CITATION_MAP.items():
        text = text.replace(old, new)
    return text


def extract_lines(lines: list[str], start: int, end: int) -> str:
    """Extract lines from 1-indexed start to end (inclusive), join as string."""
    return "".join(lines[start - 1 : end])


# ─── Main ───────────────────────────────────────────────────────────────────────

def main():
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"═══════════════════════════════════════════════════")
    print(f"  merge_nhw.py — {timestamp}")
    print(f"═══════════════════════════════════════════════════")

    # Read source
    lines = read_lines(NHW_FILE)
    total = len(lines)
    print(f"\n[1/5] Đọc nhw.tex: {total} dòng")

    # ─── Step 2: Backup ────────────────────────────────────────────────────────
    print(f"\n[2/5] Backup các file sẽ bị ghi đè...")
    targets = [
        os.path.join(SECTIONS_DIR, "sec0_overview", "01_overview.tex"),
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "01_theory.tex"),
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "02_tests.tex"),
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "03_robust_se.tex"),
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "04_example_prestige.tex"),
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "04_summary.tex"),
    ]
    for t in targets:
        backup_file(t)

    # ─── Step 3: Extract Section 0 — Tổng Quan ────────────────────────────────
    print(f"\n[3/5] Extract Section 0: Tổng Quan (dòng 147–232)...")
    # Lines 147-232: subsections inside \section{Tổng quan}
    # Skip \section{Tổng quan} at line 145 — main.tex already has it
    sec0_content = extract_lines(lines, 147, 232)
    sec0_content = apply_citation_map(sec0_content)
    write_file(
        os.path.join(SECTIONS_DIR, "sec0_overview", "01_overview.tex"),
        sec0_content,
    )

    # ─── Step 4: Extract Section 3 — Đồng Nhất Phương Sai ─────────────────────
    print(f"\n[4/5] Extract Section 3: Đồng Nhất Phương Sai (dòng 237–544)...")

    # 01_theory.tex: Khái niệm và Hệ quả (lines 239-240)
    theory = extract_lines(lines, 239, 240)
    theory = apply_citation_map(theory)
    write_file(
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "01_theory.tex"),
        theory,
    )

    # 02_tests.tex: Breusch-Pagan + White (lines 242-275)
    tests = extract_lines(lines, 242, 275)
    tests = apply_citation_map(tests)
    write_file(
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "02_tests.tex"),
        tests,
    )

    # 03_robust_se.tex: Robust SE (lines 277-291)
    robust = extract_lines(lines, 277, 291)
    robust = apply_citation_map(robust)
    write_file(
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "03_robust_se.tex"),
        robust,
    )

    # 04_example_prestige.tex: Ví dụ R + Trực quan (lines 293-544)
    example = extract_lines(lines, 293, 544)
    example = apply_citation_map(example)
    write_file(
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "04_example_prestige.tex"),
        example,
    )

    # 04_summary.tex: Bullet-point tổng hợp (lines 473-477 — embedded within example)
    # These lines are already included in 04_example_prestige above.
    # Keep 04_summary.tex with a clean extracted summary from lines 473-477
    summary = extract_lines(lines, 471, 477)
    summary = apply_citation_map(summary)
    write_file(
        os.path.join(SECTIONS_DIR, "sec3_homoscedasticity", "04_summary.tex"),
        summary,
    )

    # ─── Step 5: Update references.bib ─────────────────────────────────────────
    print(f"\n[5/5] Cập nhật references.bib...")
    bib_content = read_file(REFERENCES_BIB)

    added = []
    for key in ["galton1886", "james2013", "maddala2001", "sheather2009", "wooldridge2015"]:
        if key not in bib_content:
            added.append(key)

    if added:
        # Append missing entries
        with open(REFERENCES_BIB, "a", encoding="utf-8") as f:
            f.write(MISSING_BIB_ENTRIES)
        print(f"  ✓ Đã thêm {len(added)} bib entries: {', '.join(added)}")
    else:
        print(f"  ✓ references.bib đã có đầy đủ các entries cần thiết")

    # ─── Done ──────────────────────────────────────────────────────────────────
    print(f"\n═══════════════════════════════════════════════════")
    print(f"  ✅ HOÀN TẤT! Backup tại: {BACKUP_DIR}")
    print(f"═══════════════════════════════════════════════════")


if __name__ == "__main__":
    main()

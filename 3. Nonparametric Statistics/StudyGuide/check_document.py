"""Check the compiled document, source structure, fonts, figures and LaTeX log.

Requires PyMuPDF (import fitz), in addition to the numerical script's packages.
Run after verify_and_figures.py and latexmk. Does not modify source or PDF.
"""
from pathlib import Path
import json
import re
import unicodedata
import fitz

root = Path(__file__).resolve().parent
main = (root / "main.tex").read_text(encoding="utf-8")
inputs = re.findall(r"\\input\{([^}]+)\}", main)
assert len(inputs) == 8, f"Expected prelude, six chapters and appendix: {inputs}"
sources = []
for name in inputs:
    path = root / (name + ".tex")
    assert path.is_file(), f"Missing chapter: {path}"
    sources.append(path.read_text(encoding="utf-8"))
assert sum(len(re.findall(r"\\chapter\{", source)) for source in sources) == 7
exercise_count = sum(source.count(r"\begin{exercise}") for source in sources)
assert exercise_count == 16, f"Expected 16 exercises, got {exercise_count}"
assert sum(source.count(r"\begin{solution}") for source in sources) == 16
figures = [name for source in sources for name in re.findall(r"\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}", source)]
assert len(figures) == 7
for name in figures:
    assert (root / "figures" / name).is_file(), f"Missing figure: {name}"
report = json.loads((root / "verification.json").read_text(encoding="utf-8"))
assert report["checks_passed"] > 100
assert sorted(figures) == report["figures"]
log = (root / "main.log").read_text(encoding="utf-8", errors="replace")
blockers = [r"^!", r"Overfull \\[hv]box", r"Missing character:",
            r"(?:Citation|Reference).*undefined", r"There were undefined references",
            r"Label\(s\) may have changed", r"Rerun to get", r"multiply defined",
            r"Token not allowed in a PDF string", r"LaTeX Error"]
for pattern in blockers:
    assert not re.search(pattern, log, re.MULTILINE), f"LaTeX issue: {pattern}"
with fitz.open(root / "main.pdf") as doc:
    assert len(doc) >= 40, f"Unexpected document length: {len(doc)}"
    text = unicodedata.normalize("NFC", "\n".join(p.get_text() for p in doc))
    for expected in ["Glivenko", "Nadaraya", "Biweight", "Tricube", "Root", "Borel", "Anderson", "Talagrand"]:
        assert expected in text, f"Expected topic absent from PDF: {expected}"
    fonts = sorted({font[3] for p in doc for font in p.get_fonts()})
    assert any("LMRoman" in f for f in fonts), f"Latin Modern text font absent: {fonts}"
    assert any("LatinModernMath" in f for f in fonts), f"Latin Modern math font absent: {fonts}"
    toc = doc.get_toc()
    assert len(toc) > 40, "PDF bookmarks missing"
    assert sum("Bài 6." in line for line in text.splitlines()) >= 16, "Exercise labels absent"
    print(f"Document checks passed: {len(doc)} pages, 6 chapters, {exercise_count} solved exercises, {len(figures)} figures.")
    print("Latin Modern text and math fonts embedded; references resolved; no overflowing boxes or missing glyphs.")

"""Topic 4 (Đề tài 4) manifest — HVH: monolingual chữ Hán corpus, Vietnamese history.

Volume ids refer to https://lib.nomfoundation.org/collection/1/volume/{id}.
Extracted from the hyperlinks in "DS Đề tài KHDL.xlsx" (column "Bản Hán").
A work with several volumes is delivered as chapters HVH_xxx_01, HVH_xxx_02, ...
"""

WORKS = [
    {"code": "HVH_090", "title": "Đinh Triều Sự Chí",                     "han": "丁朝事誌",       "volumes": [746]},
    {"code": "HVH_091", "title": "Đoàn Tộc Phả",                          "han": "段族譜",         "volumes": [207]},
    {"code": "HVH_092", "title": "Độc Nhật Bản Tính Thôn Trung Quốc Chi Sách Chi Tự Văn Ký", "han": "讀日本并吞中國之策之序文記", "volumes": [750]},
    {"code": "HVH_093", "title": "Độc Sử Trích Nghi",                     "han": "讀史摘疑",       "volumes": [751]},
    {"code": "HVH_094", "title": "Đông Dương Chính Trị",                  "han": "東洋政治",       "volumes": [759]},
    {"code": "HVH_095", "title": "Đông Dương Chính Trị Địa Chí Tập Biên", "han": "東洋政治政治地誌集編", "volumes": [760]},
    {"code": "HVH_096", "title": "Đông Hải Đại Vương Sự Tích",            "han": "東海大王事跡",   "volumes": [763]},
    {"code": "HVH_097", "title": "Đông Trù Đoàn Tộc Phả",                 "han": "東稠段族譜",     "volumes": [208]},
    {"code": "HVH_098", "title": "Gia Định Thông Chí",                    "han": "嘉定通志",       "volumes": [973]},
    {"code": "HVH_099", "title": "Giang Thị Gia Phả",                     "han": "江氏家譜",       "volumes": [1158]},
    {"code": "HVH_100", "title": "Hà Nội Tỉnh Văn Miếu",                  "han": "河内省文庙",     "volumes": [773]},
    {"code": "HVH_101", "title": "Hàn Mặc Lâm",                           "han": "韓墨林",         "volumes": [216]},
    {"code": "HVH_102", "title": "Hậu Trần Dật Sử",                       "han": "後陳逸史",       "volumes": [217]},
    {"code": "HVH_103", "title": "Hoàng Minh Tứ Di",                      "han": "皇明四夷",       "volumes": [774]},
    {"code": "HVH_104", "title": "Hoàng Triều Nhất Thống Địa Dư Chí",     "han": "皇朝一統地輿誌", "volumes": [775]},
    {"code": "HVH_105", "title": "Hoàng Việt Địa Dư Chí",                 "han": "皇越地輿誌",     "volumes": [118]},
    {"code": "HVH_106", "title": "Hoàng Việt Lịch Đại Chính Yếu",         "han": "皇越歷代政要",   "volumes": [119]},
    # 21 volumes: 221 = q.01 (luật mục), 222–240 = q.02–q.20, 306 = Ngự chế Hoàng Việt luật lệ
    {"code": "HVH_107", "title": "Hoàng Việt Luật Lệ",                    "han": "皇越律例",       "volumes": [*range(221, 241), 306]},
]


def units(work):
    """Yield (unit_code, volume_id) — one unit per volume.

    Single-volume works use the work code itself; multi-volume works get
    chapter-suffixed codes per OutputRequirement.pdf (HVH_107_01, ...).
    """
    vols = work["volumes"]
    if len(vols) == 1:
        yield work["code"], vols[0]
    else:
        for i, vol in enumerate(vols, start=1):
            yield f"{work['code']}_{i:02d}", vol


def all_units():
    for work in WORKS:
        yield from units(work)


def select(argv):
    """Resolve CLI args into an ordered, de-duplicated list of (work, unit_code, volume_id).

    Accepts:
      - nothing            -> all units
      - work codes         -> "HVH_091" (expands to its unit(s))
      - unit codes         -> "HVH_107_06" (a single volume of a multi-volume work)
      - "--person P1"      -> that person's assignment list (see assignments.py)
    """
    codes = list(argv)
    if "--person" in codes:
        i = codes.index("--person")
        from assignments import ASSIGNMENTS
        person = codes[i + 1]
        if person not in ASSIGNMENTS:
            raise SystemExit(f"unknown person {person!r}; choose from {list(ASSIGNMENTS)}")
        codes = codes[:i] + codes[i + 2:] + ASSIGNMENTS[person]

    index = {}  # unit_code -> (work, unit_code, volume_id)
    work_of = {}
    for work in WORKS:
        for unit_code, vol in units(work):
            index[unit_code] = (work, unit_code, vol)
            work_of.setdefault(work["code"], []).append(unit_code)

    if not codes:
        return [index[u] for u in index]

    chosen, seen = [], set()
    for code in codes:
        unit_codes = [code] if code in index else work_of.get(code)
        if not unit_codes:
            raise SystemExit(f"unknown work/unit code: {code!r}")
        for u in unit_codes:
            if u not in seen:
                seen.add(u)
                chosen.append(index[u])
    return chosen


if __name__ == "__main__":
    import sys
    for work, code, vol in select(sys.argv[1:]):
        print(code, vol)

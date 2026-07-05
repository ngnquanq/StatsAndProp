"""Balanced 4-way split of topic 4 (~509 pages each) for load-sharing.

Computed by longest-processing-time bin-packing over per-unit page counts
(HVH_107's 21 volumes are split across people since it alone is ~half the
corpus). Each person runs only their list, from their own machine — separate
machines/IPs also means separate rate-limit buckets, so aggregate throughput
scales with the team.

Run your share with either script:
    python download_images.py --person P1
    python run_pipeline.py   --person P1
"""

ASSIGNMENTS = {
    # ~508 pages
    "P1": ["HVH_090", "HVH_092", "HVH_102",
           "HVH_107_06", "HVH_107_10", "HVH_107_11", "HVH_107_14",
           "HVH_107_17", "HVH_107_18", "HVH_107_21"],
    # ~511 pages
    "P2": ["HVH_098", "HVH_104", "HVH_106",
           "HVH_107_01", "HVH_107_04", "HVH_107_08", "HVH_107_13",
           "HVH_107_15", "HVH_107_20"],
    # ~509 pages
    "P3": ["HVH_094", "HVH_099", "HVH_101", "HVH_103", "HVH_105",
           "HVH_107_05", "HVH_107_09", "HVH_107_16", "HVH_107_19"],
    # ~508 pages
    "P4": ["HVH_091", "HVH_093", "HVH_095", "HVH_096", "HVH_097", "HVH_100",
           "HVH_107_02", "HVH_107_03", "HVH_107_07", "HVH_107_12"],
}

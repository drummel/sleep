"""Compatibility pairing logic — mirrors web/app/lib/compatibility.ts exactly."""

from __future__ import annotations

from typing import TypedDict

VALID_CHRONOTYPES = {"lion", "bear", "wolf", "dolphin"}


class PairingInfo(TypedDict):
    name: str
    best_window: str
    gap_window: str
    worth_knowing: str
    overlap_score: int


def _pairing_key(a: str, b: str) -> str:
    """Canonical key: alphabetical sort so order doesn't matter."""
    return "_".join(sorted([a, b]))


# ---------------------------------------------------------------------------
# All 10 unique pairings — identical to web/app/lib/compatibility.ts
# ---------------------------------------------------------------------------

_PAIRINGS: dict[str, PairingInfo] = {
    "wolf_wolf": {
        "name": "The Late Night Society",
        "best_window": "6:00 PM \u2013 11:00 PM",
        "gap_window": "Mornings are nobody's problem",
        "worth_knowing": "You both peak late \u2014 your evenings are electric, but you'll need external structure for mornings.",
        "overlap_score": 5,
    },
    "bear_wolf": {
        "name": "The Night Owl and the Middler",
        "best_window": "4:00 PM \u2013 8:00 PM",
        "gap_window": "Mornings (Bear is up; Wolf is not)",
        "worth_knowing": "The Bear can ease into the day while the Wolf ramps up. Your overlap lives in late afternoon.",
        "overlap_score": 3,
    },
    "lion_wolf": {
        "name": "The Midnight Sun Pair",
        "best_window": "12:00 PM \u2013 3:00 PM",
        "gap_window": "Early morning and late evening \u2014 you're on opposite schedules",
        "worth_knowing": "This is the hardest pairing for shared time. Protect your midday overlap like it's sacred.",
        "overlap_score": 1,
    },
    "dolphin_wolf": {
        "name": "Two Restless Ones",
        "best_window": "5:00 PM \u2013 9:00 PM",
        "gap_window": "Mornings are rough for both, but for different reasons",
        "worth_knowing": "You both resist conventional schedules. The evening is your playground \u2014 lean into it.",
        "overlap_score": 3,
    },
    "bear_bear": {
        "name": "The Solid Eight",
        "best_window": "9:00 AM \u2013 9:00 PM",
        "gap_window": "Minimal \u2014 you're naturally in sync",
        "worth_knowing": "You're the most common pairing and the most naturally aligned. Don't take the harmony for granted.",
        "overlap_score": 5,
    },
    "bear_lion": {
        "name": "The Early Start and the Steady State",
        "best_window": "8:00 AM \u2013 6:00 PM",
        "gap_window": "Early morning (Lion is up; Bear is warming up)",
        "worth_knowing": "The Lion gets a head start each day. By mid-morning you're in perfect sync.",
        "overlap_score": 4,
    },
    "bear_dolphin": {
        "name": "The Easygoing and the Alert",
        "best_window": "10:00 AM \u2013 7:00 PM",
        "gap_window": "Bedtime (Dolphin takes longer to wind down)",
        "worth_knowing": "The Bear's steady rhythm can be grounding for the Dolphin's variable energy.",
        "overlap_score": 3,
    },
    "lion_lion": {
        "name": "The Dawn Chorus",
        "best_window": "6:00 AM \u2013 2:00 PM",
        "gap_window": "Evenings \u2014 you're both fading fast",
        "worth_knowing": "Your mornings are powerful together. Plan dates before sunset \u2014 you'll both be asleep by 10.",
        "overlap_score": 5,
    },
    "dolphin_lion": {
        "name": "The Early Riser and the Light Sleeper",
        "best_window": "7:00 AM \u2013 1:00 PM",
        "gap_window": "Bedtime misalignment \u2014 Lion crashes, Dolphin's mind races",
        "worth_knowing": "The Lion's predictable rhythm helps stabilize the Dolphin. Mornings together are your anchor.",
        "overlap_score": 3,
    },
    "dolphin_dolphin": {
        "name": "The Midnight Overthinkers",
        "best_window": "10:00 AM \u2013 8:00 PM",
        "gap_window": "Late night \u2014 two active minds, no off switch",
        "worth_knowing": "You understand each other's restlessness. Build a shared wind-down ritual \u2014 you both need one.",
        "overlap_score": 4,
    },
}


def get_pairing(type_a: str, type_b: str) -> PairingInfo:
    """Look up compatibility info for two chronotype IDs.

    Raises:
        ValueError: If either type is not a valid chronotype ID, or the pairing
                    is not found (should never happen if types are valid).
    """
    for t, label in [(type_a, "self_type"), (type_b, "partner_type")]:
        if t not in VALID_CHRONOTYPES:
            raise ValueError(f"Invalid {label}: '{t}'. Must be one of {sorted(VALID_CHRONOTYPES)}")

    key = _pairing_key(type_a, type_b)
    info = _PAIRINGS.get(key)
    if info is None:
        raise ValueError(f"Pairing not found for key '{key}'")
    return info


def get_all_pairings() -> list[dict]:
    """Return all pairings with their type_a / type_b labels."""
    results = []
    for key, info in _PAIRINGS.items():
        parts = key.split("_")
        results.append({"type_a": parts[0], "type_b": parts[1], **info})
    return results

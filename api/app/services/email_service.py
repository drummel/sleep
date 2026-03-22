"""Mock email / waitlist service for the experiment phase.

All data is stored in-memory. In production this would integrate with a
real email provider (Resend, SendGrid, etc.) and a database.
"""

from __future__ import annotations

import hashlib
import time
from typing import Any

# ---------------------------------------------------------------------------
# In-memory stores
# ---------------------------------------------------------------------------

_waitlist_entries: list[dict[str, Any]] = []
_survey_entries: list[dict[str, Any]] = []


def _generate_referral_code(email: str) -> str:
    """Deterministic but opaque referral code from email + timestamp."""
    raw = f"{email}-{time.time()}"
    return "SP-" + hashlib.sha256(raw.encode()).hexdigest()[:8].upper()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def join_waitlist(
    email: str,
    waitlist_id: str = "sleeppath_launch",
    metadata: dict[str, Any] | None = None,
) -> str:
    """Add an email to the waitlist and return a referral code."""
    referral_code = _generate_referral_code(email)

    entry = {
        "email": email,
        "waitlist_id": waitlist_id,
        "referral_code": referral_code,
        "metadata": metadata or {},
        "created_at": time.time(),
    }
    _waitlist_entries.append(entry)
    return referral_code


def submit_survey(
    email: str,
    chronotype: str,
    goal: str,
    features: list[str],
    track: str = "individual",
) -> None:
    """Store a feature-survey submission."""
    entry = {
        "email": email,
        "chronotype": chronotype,
        "goal": goal,
        "features": features,
        "track": track,
        "created_at": time.time(),
    }
    _survey_entries.append(entry)


def get_waitlist_entries() -> list[dict[str, Any]]:
    """Return all waitlist entries (admin/testing helper)."""
    return list(_waitlist_entries)


def get_survey_entries() -> list[dict[str, Any]]:
    """Return all survey entries (admin/testing helper)."""
    return list(_survey_entries)


def clear_stores() -> None:
    """Reset in-memory stores (useful in tests)."""
    _waitlist_entries.clear()
    _survey_entries.clear()

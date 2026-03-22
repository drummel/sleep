from typing import Any

from pydantic import BaseModel, EmailStr, Field


# ---------------------------------------------------------------------------
# Quiz
# ---------------------------------------------------------------------------

class QuizAnswerRequest(BaseModel):
    """Client submits a list of answer indices (0-3), one per question."""
    answers: list[int] = Field(..., min_length=1, max_length=8)


class ChronotypeScores(BaseModel):
    lion: int = 0
    bear: int = 0
    wolf: int = 0
    dolphin: int = 0


class QuizResultResponse(BaseModel):
    chronotype: str
    scores: ChronotypeScores
    goal: str


# ---------------------------------------------------------------------------
# Compatibility
# ---------------------------------------------------------------------------

class CompatibilityRequest(BaseModel):
    self_type: str
    partner_type: str


class CompatibilityResponse(BaseModel):
    pairing_name: str
    best_window: str
    gap_window: str
    worth_knowing: str
    overlap_score: int


# ---------------------------------------------------------------------------
# Email / Waitlist
# ---------------------------------------------------------------------------

class EmailSignupRequest(BaseModel):
    email: EmailStr
    chronotype: str
    track: str = "individual"
    waitlist_id: str = "sleeppath_launch"
    metadata: dict[str, Any] = Field(default_factory=dict)


class EmailSignupResponse(BaseModel):
    success: bool
    referral_code: str


class FeatureSurveyRequest(BaseModel):
    email: EmailStr
    chronotype: str
    goal: str = ""
    features: list[str] = Field(default_factory=list)
    track: str = "individual"


class FeatureSurveyResponse(BaseModel):
    success: bool


# ---------------------------------------------------------------------------
# Share Links
# ---------------------------------------------------------------------------

class ShareLinksRequest(BaseModel):
    referral_code: str
    text: str = ""
    url: str = ""


class ShareLinksResponse(BaseModel):
    twitter: str
    whatsapp: str
    copy_url: str

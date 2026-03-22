"""Waitlist endpoints — email signup and feature survey."""

from fastapi import APIRouter

from app.schemas.quiz import (
    EmailSignupRequest,
    EmailSignupResponse,
    FeatureSurveyRequest,
    FeatureSurveyResponse,
)
from app.services.email_service import join_waitlist, submit_survey

router = APIRouter(prefix="/v1/waitlist", tags=["waitlist"])


@router.post("/join", response_model=EmailSignupResponse)
async def waitlist_join(payload: EmailSignupRequest) -> EmailSignupResponse:
    """Add an email to the waitlist and return a referral code."""
    referral_code = join_waitlist(
        email=payload.email,
        waitlist_id=payload.waitlist_id,
        metadata={"chronotype": payload.chronotype, "track": payload.track, **payload.metadata},
    )
    return EmailSignupResponse(success=True, referral_code=referral_code)


@router.post("/survey", response_model=FeatureSurveyResponse)
async def waitlist_survey(payload: FeatureSurveyRequest) -> FeatureSurveyResponse:
    """Submit a feature-priority survey."""
    submit_survey(
        email=payload.email,
        chronotype=payload.chronotype,
        goal=payload.goal,
        features=payload.features,
        track=payload.track,
    )
    return FeatureSurveyResponse(success=True)

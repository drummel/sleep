"""Quiz endpoints — score answers and serve questions."""

from fastapi import APIRouter, HTTPException

from app.schemas.quiz import QuizAnswerRequest, QuizResultResponse
from app.services.quiz_service import calculate_chronotype, get_questions

router = APIRouter(prefix="/v1/quiz", tags=["quiz"])


@router.post("/score", response_model=QuizResultResponse)
async def score_quiz(payload: QuizAnswerRequest) -> QuizResultResponse:
    """Score a set of quiz answers and return the dominant chronotype."""
    try:
        result = calculate_chronotype(payload.answers)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    return QuizResultResponse(
        chronotype=result["chronotype"],
        scores=result["scores"],
        goal=result["goal"],
    )


@router.get("/questions")
async def list_questions() -> list[dict]:
    """Return all quiz questions for a server-driven quiz flow."""
    return get_questions()

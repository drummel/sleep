"""Chronotype quiz scoring — mirrors the frontend logic exactly."""

from __future__ import annotations

from typing import Any, TypedDict

VALID_CHRONOTYPES = {"lion", "bear", "wolf", "dolphin"}


class PointMap(TypedDict):
    lion: int
    bear: int
    wolf: int
    dolphin: int


class QuizAnswer(TypedDict):
    text: str
    points: PointMap


class QuizQuestion(TypedDict):
    id: int
    question: str
    context: str
    answers: list[QuizAnswer]


# ---------------------------------------------------------------------------
# Questions — identical to web/app/lib/quiz-questions.ts
# ---------------------------------------------------------------------------

QUIZ_QUESTIONS: list[QuizQuestion] = [
    {
        "id": 1,
        "question": "What time do you naturally wake up on days with no alarm?",
        "context": "Think about weekends or vacations \u2014 when your body decides.",
        "answers": [
            {"text": "Before 6:30 AM", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 1}},
            {"text": "6:30 \u2013 8:00 AM", "points": {"lion": 1, "bear": 3, "wolf": 0, "dolphin": 1}},
            {"text": "8:00 \u2013 10:00 AM", "points": {"lion": 0, "bear": 1, "wolf": 3, "dolphin": 0}},
            {"text": "It varies wildly", "points": {"lion": 0, "bear": 0, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 2,
        "question": "When do you feel your sharpest during the day?",
        "context": "When is your brain on fire \u2014 solving hard problems, writing, creating?",
        "answers": [
            {"text": "First thing in the morning", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 0}},
            {"text": "Late morning to early afternoon", "points": {"lion": 1, "bear": 3, "wolf": 0, "dolphin": 1}},
            {"text": "Late afternoon to evening", "points": {"lion": 0, "bear": 1, "wolf": 3, "dolphin": 1}},
            {"text": "It comes in unpredictable bursts", "points": {"lion": 0, "bear": 0, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 3,
        "question": "How would you describe your sleep quality?",
        "context": "On a typical night, not your best or worst.",
        "answers": [
            {"text": "I sleep deeply and wake refreshed", "points": {"lion": 2, "bear": 3, "wolf": 1, "dolphin": 0}},
            {"text": "Pretty solid \u2014 occasional restlessness", "points": {"lion": 2, "bear": 2, "wolf": 1, "dolphin": 1}},
            {"text": "I struggle to fall asleep but sleep well eventually", "points": {"lion": 0, "bear": 0, "wolf": 3, "dolphin": 1}},
            {"text": "Light and fitful \u2014 I wake up often", "points": {"lion": 0, "bear": 0, "wolf": 0, "dolphin": 3}},
        ],
    },
    {
        "id": 4,
        "question": "When do you prefer to exercise?",
        "context": "If you had total control over your schedule.",
        "answers": [
            {"text": "Early morning \u2014 before the day starts", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 1}},
            {"text": "Mid-day or lunch break", "points": {"lion": 1, "bear": 3, "wolf": 0, "dolphin": 1}},
            {"text": "Evening \u2014 after work or dinner", "points": {"lion": 0, "bear": 1, "wolf": 3, "dolphin": 0}},
            {"text": "Whenever I actually have the energy", "points": {"lion": 0, "bear": 0, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 5,
        "question": "If you could eat dinner at any time, when would it be?",
        "context": "No social obligations \u2014 just your body's preference.",
        "answers": [
            {"text": "5:30 \u2013 6:30 PM", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 1}},
            {"text": "6:30 \u2013 7:30 PM", "points": {"lion": 1, "bear": 3, "wolf": 1, "dolphin": 1}},
            {"text": "8:00 \u2013 9:30 PM", "points": {"lion": 0, "bear": 1, "wolf": 3, "dolphin": 0}},
            {"text": "My hunger doesn't follow a pattern", "points": {"lion": 0, "bear": 0, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 6,
        "question": "How do you feel about mornings?",
        "context": "Be honest \u2014 not aspirational.",
        "answers": [
            {"text": "I love them \u2014 best part of my day", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 0}},
            {"text": "Fine once I'm up and moving", "points": {"lion": 1, "bear": 3, "wolf": 0, "dolphin": 1}},
            {"text": "They're painful \u2014 I'm a zombie until 10 AM", "points": {"lion": 0, "bear": 0, "wolf": 3, "dolphin": 1}},
            {"text": "Depends on the night \u2014 sometimes great, sometimes awful", "points": {"lion": 0, "bear": 1, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 7,
        "question": "How quickly do you fall asleep at night?",
        "context": "When you actually get into bed intending to sleep.",
        "answers": [
            {"text": "Within 5 minutes \u2014 I'm out", "points": {"lion": 3, "bear": 2, "wolf": 0, "dolphin": 0}},
            {"text": "10\u201320 minutes \u2014 fairly normal", "points": {"lion": 1, "bear": 3, "wolf": 1, "dolphin": 0}},
            {"text": "20\u201345 minutes \u2014 my mind takes a while to wind down", "points": {"lion": 0, "bear": 0, "wolf": 3, "dolphin": 1}},
            {"text": "45+ minutes \u2014 my brain won't shut off", "points": {"lion": 0, "bear": 0, "wolf": 1, "dolphin": 3}},
        ],
    },
    {
        "id": 8,
        "question": "What's your biggest sleep-related goal?",
        "context": "The one thing that would change your daily experience the most.",
        "answers": [
            {"text": "Protect my morning routine and wind down earlier", "points": {"lion": 3, "bear": 1, "wolf": 0, "dolphin": 0}},
            {"text": "Build more consistency \u2014 same time every day", "points": {"lion": 1, "bear": 3, "wolf": 1, "dolphin": 1}},
            {"text": "Actually work with my night-owl schedule, not fight it", "points": {"lion": 0, "bear": 0, "wolf": 3, "dolphin": 0}},
            {"text": "Figure out why my sleep is so unpredictable", "points": {"lion": 0, "bear": 0, "wolf": 0, "dolphin": 3}},
        ],
    },
]


class QuizResult(TypedDict):
    chronotype: str
    scores: dict[str, int]
    goal: str


def calculate_chronotype(answers: list[int]) -> QuizResult:
    """Score quiz answers and return the dominant chronotype.

    Args:
        answers: List of answer indices (0-3), one per answered question.

    Returns:
        Dict with chronotype id, all scores, and the user's goal text.

    Raises:
        ValueError: If any answer index is out of range for its question.
    """
    scores: dict[str, int] = {"lion": 0, "bear": 0, "wolf": 0, "dolphin": 0}

    for question_idx, answer_idx in enumerate(answers):
        if question_idx >= len(QUIZ_QUESTIONS):
            break
        question = QUIZ_QUESTIONS[question_idx]
        if answer_idx < 0 or answer_idx >= len(question["answers"]):
            raise ValueError(
                f"Answer index {answer_idx} out of range for question {question_idx + 1} "
                f"(expected 0\u2013{len(question['answers']) - 1})"
            )
        points = question["answers"][answer_idx]["points"]
        for key in scores:
            scores[key] += points[key]

    # Dominant chronotype — highest score wins; ties broken by dict ordering
    chronotype = max(scores, key=lambda k: scores[k])

    # Goal comes from the last answered question (question 8)
    goal = ""
    last_q_idx = len(QUIZ_QUESTIONS) - 1
    if len(answers) > last_q_idx:
        goal_answer_idx = answers[last_q_idx]
        goal = QUIZ_QUESTIONS[last_q_idx]["answers"][goal_answer_idx]["text"]

    return {"chronotype": chronotype, "scores": scores, "goal": goal}


def get_questions() -> list[dict[str, Any]]:
    """Return quiz questions in a JSON-friendly format."""
    return [dict(q) for q in QUIZ_QUESTIONS]

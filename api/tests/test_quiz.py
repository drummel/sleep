import pytest

from app.services.quiz_service import calculate_chronotype, get_questions


class TestCalculateChronotype:
    def test_all_lion_answers(self):
        answers = [0, 0, 0, 0, 0, 0, 0, 0]
        result = calculate_chronotype(answers)
        assert result["chronotype"] == "lion"
        assert result["scores"]["lion"] > result["scores"]["bear"]
        assert result["scores"]["lion"] > result["scores"]["wolf"]
        assert result["scores"]["lion"] > result["scores"]["dolphin"]

    def test_all_bear_answers(self):
        answers = [1, 1, 1, 1, 1, 1, 1, 1]
        result = calculate_chronotype(answers)
        assert result["chronotype"] == "bear"

    def test_all_wolf_answers(self):
        answers = [2, 2, 2, 2, 2, 2, 2, 2]
        result = calculate_chronotype(answers)
        assert result["chronotype"] == "wolf"

    def test_all_dolphin_answers(self):
        answers = [3, 3, 3, 3, 3, 3, 3, 3]
        result = calculate_chronotype(answers)
        assert result["chronotype"] == "dolphin"

    def test_goal_from_last_question(self):
        answers = [0, 0, 0, 0, 0, 0, 0, 0]
        result = calculate_chronotype(answers)
        assert result["goal"] == "Protect my morning routine and wind down earlier"

    def test_goal_wolf(self):
        answers = [2, 2, 2, 2, 2, 2, 2, 2]
        result = calculate_chronotype(answers)
        assert result["goal"] == "Actually work with my night-owl schedule, not fight it"

    def test_partial_answers(self):
        answers = [0, 0, 0]
        result = calculate_chronotype(answers)
        assert result["chronotype"] in {"lion", "bear", "wolf", "dolphin"}
        assert result["goal"] == ""

    def test_empty_answers(self):
        result = calculate_chronotype([])
        assert result["chronotype"] == "lion"
        assert all(v == 0 for v in result["scores"].values())

    def test_invalid_answer_index_raises(self):
        with pytest.raises(ValueError, match="out of range"):
            calculate_chronotype([5, 0, 0, 0, 0, 0, 0, 0])

    def test_negative_answer_index_raises(self):
        with pytest.raises(ValueError, match="out of range"):
            calculate_chronotype([-1, 0, 0, 0, 0, 0, 0, 0])

    def test_scores_structure(self):
        answers = [0, 1, 2, 3, 0, 1, 2, 3]
        result = calculate_chronotype(answers)
        for key in ["lion", "bear", "wolf", "dolphin"]:
            assert key in result["scores"]
            assert isinstance(result["scores"][key], int)

    def test_wolf_total_score(self):
        answers = [2, 2, 2, 2, 2, 2, 2, 2]
        result = calculate_chronotype(answers)
        assert result["scores"]["wolf"] == 24


class TestGetQuestions:
    def test_returns_8_questions(self):
        assert len(get_questions()) == 8

    def test_each_question_has_4_answers(self):
        for q in get_questions():
            assert len(q["answers"]) == 4

    def test_question_structure(self):
        for q in get_questions():
            assert "id" in q
            assert "question" in q
            assert "context" in q
            assert "answers" in q

    def test_answer_points_structure(self):
        for q in get_questions():
            for a in q["answers"]:
                assert "text" in a
                pts = a["points"]
                for k in ["lion", "bear", "wolf", "dolphin"]:
                    assert k in pts

    def test_question_ids_sequential(self):
        ids = [q["id"] for q in get_questions()]
        assert ids == list(range(1, 9))


class TestScoreEndpoint:
    @pytest.mark.asyncio
    async def test_score_lion(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [0]*8})
        assert resp.status_code == 200
        assert resp.json()["chronotype"] == "lion"

    @pytest.mark.asyncio
    async def test_score_wolf(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [2]*8})
        assert resp.status_code == 200
        assert resp.json()["chronotype"] == "wolf"

    @pytest.mark.asyncio
    async def test_score_bear(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [1]*8})
        assert resp.status_code == 200
        assert resp.json()["chronotype"] == "bear"

    @pytest.mark.asyncio
    async def test_score_dolphin(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [3]*8})
        assert resp.status_code == 200
        assert resp.json()["chronotype"] == "dolphin"

    @pytest.mark.asyncio
    async def test_score_invalid(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [5]*8})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_score_empty(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": []})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_score_too_many(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [0]*10})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_score_partial(self, client):
        resp = await client.post("/v1/quiz/score", json={"answers": [0, 0, 0]})
        assert resp.status_code == 200

    @pytest.mark.asyncio
    async def test_score_missing_body(self, client):
        resp = await client.post("/v1/quiz/score")
        assert resp.status_code == 422


class TestQuestionsEndpoint:
    @pytest.mark.asyncio
    async def test_list_questions(self, client):
        resp = await client.get("/v1/quiz/questions")
        assert resp.status_code == 200
        assert len(resp.json()) == 8

    @pytest.mark.asyncio
    async def test_questions_structure(self, client):
        resp = await client.get("/v1/quiz/questions")
        for q in resp.json():
            assert "id" in q
            assert "question" in q
            assert len(q["answers"]) == 4

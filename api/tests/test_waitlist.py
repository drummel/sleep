import pytest

from app.services.email_service import (
    clear_stores, get_survey_entries, get_waitlist_entries,
    join_waitlist, submit_survey,
)


class TestJoinWaitlist:
    def test_returns_referral_code(self):
        code = join_waitlist("test@example.com")
        assert code.startswith("SP-")
        assert len(code) == 11

    def test_stores_entry(self):
        join_waitlist("test@example.com", waitlist_id="wl_solo")
        entries = get_waitlist_entries()
        assert len(entries) == 1
        assert entries[0]["email"] == "test@example.com"
        assert entries[0]["waitlist_id"] == "wl_solo"

    def test_stores_metadata(self):
        join_waitlist("test@example.com", metadata={"chronotype": "wolf"})
        assert get_waitlist_entries()[0]["metadata"]["chronotype"] == "wolf"

    def test_multiple_signups(self):
        join_waitlist("a@example.com")
        join_waitlist("b@example.com")
        assert len(get_waitlist_entries()) == 2

    def test_unique_codes(self):
        c1 = join_waitlist("a@example.com")
        c2 = join_waitlist("b@example.com")
        assert c1 != c2

    def test_default_waitlist_id(self):
        join_waitlist("test@example.com")
        assert get_waitlist_entries()[0]["waitlist_id"] == "sleeppath_launch"


class TestSubmitSurvey:
    def test_stores_survey(self):
        submit_survey("test@example.com", "wolf", "goal", ["adaptive_engine", "caffeine_cutoff"])
        entries = get_survey_entries()
        assert len(entries) == 1
        assert entries[0]["chronotype"] == "wolf"
        assert "adaptive_engine" in entries[0]["features"]

    def test_survey_track(self):
        submit_survey("t@e.com", "bear", "g", ["weekly_patterns"], track="compatibility")
        assert get_survey_entries()[0]["track"] == "compatibility"

    def test_survey_empty_features(self):
        submit_survey("t@e.com", "lion", "g", [])
        assert get_survey_entries()[0]["features"] == []


class TestClearStores:
    def test_clears_both(self):
        join_waitlist("test@example.com")
        submit_survey("test@example.com", "wolf", "goal", ["feat"])
        clear_stores()
        assert len(get_waitlist_entries()) == 0
        assert len(get_survey_entries()) == 0


class TestWaitlistJoinEndpoint:
    @pytest.mark.asyncio
    async def test_join(self, client):
        resp = await client.post("/v1/waitlist/join", json={
            "email": "test@example.com", "chronotype": "wolf", "track": "solo",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["referral_code"].startswith("SP-")

    @pytest.mark.asyncio
    async def test_join_partner_mode(self, client):
        resp = await client.post("/v1/waitlist/join", json={
            "email": "couple@example.com", "chronotype": "bear",
            "track": "compatibility", "waitlist_id": "wl_partner_mode",
            "metadata": {"pairing": "wolf_bear"},
        })
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    @pytest.mark.asyncio
    async def test_invalid_email(self, client):
        resp = await client.post("/v1/waitlist/join", json={
            "email": "not-an-email", "chronotype": "wolf",
        })
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_missing_email(self, client):
        resp = await client.post("/v1/waitlist/join", json={"chronotype": "wolf"})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_missing_chronotype(self, client):
        resp = await client.post("/v1/waitlist/join", json={"email": "test@example.com"})
        assert resp.status_code == 422


class TestSurveyEndpoint:
    @pytest.mark.asyncio
    async def test_submit(self, client):
        resp = await client.post("/v1/waitlist/survey", json={
            "email": "test@example.com", "chronotype": "wolf",
            "goal": "Work with my schedule",
            "features": ["adaptive_engine", "caffeine_cutoff", "partner_mode"],
            "track": "solo",
        })
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    @pytest.mark.asyncio
    async def test_empty_features(self, client):
        resp = await client.post("/v1/waitlist/survey", json={
            "email": "test@example.com", "chronotype": "bear", "features": [],
        })
        assert resp.status_code == 200

    @pytest.mark.asyncio
    async def test_invalid_email(self, client):
        resp = await client.post("/v1/waitlist/survey", json={
            "email": "bad", "chronotype": "wolf", "features": ["adaptive_engine"],
        })
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_missing_body(self, client):
        resp = await client.post("/v1/waitlist/survey")
        assert resp.status_code == 422

import pytest

from app.services.compatibility_service import get_all_pairings, get_pairing


class TestGetPairing:
    @pytest.mark.parametrize("a,b,expected_name", [
        ("wolf", "wolf", "The Late Night Society"),
        ("bear", "wolf", "The Night Owl and the Middler"),
        ("lion", "wolf", "The Midnight Sun Pair"),
        ("dolphin", "wolf", "Two Restless Ones"),
        ("bear", "bear", "The Solid Eight"),
        ("bear", "lion", "The Early Start and the Steady State"),
        ("bear", "dolphin", "The Easygoing and the Alert"),
        ("lion", "lion", "The Dawn Chorus"),
        ("dolphin", "lion", "The Early Riser and the Light Sleeper"),
        ("dolphin", "dolphin", "The Midnight Overthinkers"),
    ])
    def test_all_10_pairings(self, a, b, expected_name):
        info = get_pairing(a, b)
        assert info["name"] == expected_name

    @pytest.mark.parametrize("a,b", [
        ("wolf", "bear"), ("lion", "bear"), ("dolphin", "bear"),
        ("wolf", "lion"), ("wolf", "dolphin"), ("lion", "dolphin"),
    ])
    def test_symmetry(self, a, b):
        info1 = get_pairing(a, b)
        info2 = get_pairing(b, a)
        assert info1["name"] == info2["name"]
        assert info1["best_window"] == info2["best_window"]

    def test_pairing_has_all_fields(self):
        info = get_pairing("wolf", "bear")
        for key in ["name", "best_window", "gap_window", "worth_knowing", "overlap_score"]:
            assert key in info

    def test_overlap_score_range(self):
        for a in ["lion", "bear", "wolf", "dolphin"]:
            for b in ["lion", "bear", "wolf", "dolphin"]:
                info = get_pairing(a, b)
                assert 1 <= info["overlap_score"] <= 5

    def test_invalid_self_type(self):
        with pytest.raises(ValueError, match="Invalid self_type"):
            get_pairing("cat", "wolf")

    def test_invalid_partner_type(self):
        with pytest.raises(ValueError, match="Invalid partner_type"):
            get_pairing("wolf", "cat")

    def test_both_invalid(self):
        with pytest.raises(ValueError):
            get_pairing("cat", "dog")


class TestGetAllPairings:
    def test_returns_10_pairings(self):
        assert len(get_all_pairings()) == 10

    def test_pairing_structure(self):
        for p in get_all_pairings():
            assert "type_a" in p
            assert "type_b" in p
            assert "name" in p
            assert "best_window" in p

    def test_all_names_unique(self):
        names = [p["name"] for p in get_all_pairings()]
        assert len(names) == len(set(names))


class TestCompatibilityEndpoint:
    @pytest.mark.asyncio
    async def test_check_compatibility(self, client):
        resp = await client.post(
            "/v1/compatibility",
            json={"self_type": "wolf", "partner_type": "bear"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["pairing_name"] == "The Night Owl and the Middler"

    @pytest.mark.asyncio
    async def test_check_symmetric(self, client):
        r1 = await client.post("/v1/compatibility", json={"self_type": "wolf", "partner_type": "bear"})
        r2 = await client.post("/v1/compatibility", json={"self_type": "bear", "partner_type": "wolf"})
        assert r1.json()["pairing_name"] == r2.json()["pairing_name"]

    @pytest.mark.asyncio
    async def test_same_type(self, client):
        resp = await client.post("/v1/compatibility", json={"self_type": "lion", "partner_type": "lion"})
        assert resp.status_code == 200
        assert resp.json()["pairing_name"] == "The Dawn Chorus"

    @pytest.mark.asyncio
    async def test_invalid_self(self, client):
        resp = await client.post("/v1/compatibility", json={"self_type": "cat", "partner_type": "wolf"})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_invalid_partner(self, client):
        resp = await client.post("/v1/compatibility", json={"self_type": "wolf", "partner_type": "cat"})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_missing_fields(self, client):
        resp = await client.post("/v1/compatibility", json={"self_type": "wolf"})
        assert resp.status_code == 422

    @pytest.mark.asyncio
    async def test_all_16_combos(self, client):
        for a in ["lion", "bear", "wolf", "dolphin"]:
            for b in ["lion", "bear", "wolf", "dolphin"]:
                resp = await client.post("/v1/compatibility", json={"self_type": a, "partner_type": b})
                assert resp.status_code == 200


class TestPairingsListEndpoint:
    @pytest.mark.asyncio
    async def test_list_pairings(self, client):
        resp = await client.get("/v1/compatibility/pairings")
        assert resp.status_code == 200
        assert len(resp.json()) == 10

    @pytest.mark.asyncio
    async def test_pairings_structure(self, client):
        for p in (await client.get("/v1/compatibility/pairings")).json():
            assert "type_a" in p
            assert "name" in p

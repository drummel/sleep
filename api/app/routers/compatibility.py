"""Compatibility endpoints — look up pairings between chronotypes."""

from fastapi import APIRouter, HTTPException

from app.schemas.quiz import CompatibilityRequest, CompatibilityResponse
from app.services.compatibility_service import get_all_pairings, get_pairing

router = APIRouter(prefix="/v1/compatibility", tags=["compatibility"])


@router.post("", response_model=CompatibilityResponse)
async def check_compatibility(payload: CompatibilityRequest) -> CompatibilityResponse:
    """Get compatibility info for two chronotypes."""
    try:
        info = get_pairing(payload.self_type, payload.partner_type)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    return CompatibilityResponse(
        pairing_name=info["name"],
        best_window=info["best_window"],
        gap_window=info["gap_window"],
        worth_knowing=info["worth_knowing"],
        overlap_score=info["overlap_score"],
    )


@router.get("/pairings")
async def list_pairings() -> list[dict]:
    """Return all 10 compatibility pairings."""
    return get_all_pairings()

import os

os.environ["TESTING"] = "True"

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.services.email_service import clear_stores


@pytest.fixture(autouse=True)
def _clean_stores():
    """Reset in-memory stores between tests."""
    clear_stores()
    yield
    clear_stores()


@pytest_asyncio.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        yield c

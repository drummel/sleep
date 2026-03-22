"""Dev server entry point for concurrently integration."""

import os

import uvicorn

if __name__ == "__main__":
    port = int(os.environ.get("API_PORT", 8001))
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        reload_excludes=[".venv"],
    )

FROM python:3.12-slim

WORKDIR /app

# Install uv so we can use the lock file for reproducible builds.
# This ensures Railway gets the exact same package versions as local dev.
RUN pip install --no-cache-dir uv

# Copy dependency files first so Docker can cache this layer.
COPY pyproject.toml uv.lock README.md LICENSE ./
COPY paper_search_mcp/ paper_search_mcp/

# --frozen: fail if lock file is out of date (never silently upgrade)
# --no-dev: skip development dependencies (tests, linters, etc.)
RUN uv sync --frozen --no-dev

# Railway injects PORT at runtime; 8000 is the fallback for local docker runs.
ENV PORT=8000
EXPOSE 8000

# Academic source API keys — override at runtime via Railway environment variables.
ENV PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=""
ENV PAPER_SEARCH_MCP_CORE_API_KEY=""
ENV PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY=""
ENV PAPER_SEARCH_MCP_ZENODO_ACCESS_TOKEN=""
ENV PAPER_SEARCH_MCP_DOAJ_API_KEY=""
ENV PAPER_SEARCH_MCP_GOOGLE_SCHOLAR_PROXY_URL=""
ENV PAPER_SEARCH_MCP_IEEE_API_KEY=""
ENV PAPER_SEARCH_MCP_ACM_API_KEY=""

# uv run resolves the entry point from the lock file's virtual environment.
CMD ["uv", "run", "paper-search-mcp"]

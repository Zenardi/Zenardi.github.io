---
name: Azure FinOps Optimizer
tools: [Python, FastAPI, Next.js, Azure, PostgreSQL, Grafana, Docker]
description: A cost analysis and optimization platform for Azure that collects spending and utilization data, generates AI-powered right-sizing recommendations, and executes remediation actions through guarded approval workflows.
external_url: https://github.com/Zenardi/azure-finops
---

**Azure FinOps Optimizer** is a comprehensive cost-management platform for Microsoft Azure subscriptions. It collects spending data from the Azure Cost Management API and utilization metrics from Azure Monitor, then uses AI (Anthropic Claude, with an OpenAI-compatible fallback) to generate intelligent right-sizing and shutdown recommendations.

## Highlights

- **Cost & consumption analysis** across resources, regions, and resource types via Azure Cost Management.
- **AI-powered recommendations** for right-sizing, deallocation, and cleanup.
- **Guarded remediation** — execute deallocate / resize / delete actions behind dry-run safeguards and approval workflows.
- **Grafana dashboards** for cost visualization, backed by PostgreSQL / TimescaleDB.
- **CLI and web UI** access (Python/FastAPI + Typer backend, Next.js/TypeScript frontend).
- **Multi-subscription support** and a mock mode for testing without live Azure credentials.
- Runs locally via **Docker Compose**.

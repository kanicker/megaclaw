# Installer Assets

This folder contains a minimal installer + quickstart for customers.

## Files
- **install.sh** — one-command setup for Dockerized OpenClaw
- **QUICKSTART.md** — short docs for customers

## What it does
- Checks Docker
- Clones OpenClaw into ~/openclaw-docker
- Writes .env with safe defaults and non-conflicting ports
- Starts the gateway
- Runs setup

## Post‑install
Open the dashboard and add your LLM provider key.

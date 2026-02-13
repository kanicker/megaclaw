# Daily Predictions — End‑of‑Day Workflow

## What it does
At end of day, it reads today’s memory log and writes:
- Summary
- Predictions for tomorrow
- Context to carry forward

…into **tomorrow’s** `memory/YYYY‑MM‑DD.md`.

## Run manually
```bash
chmod +x daily-prediction.sh
./daily-prediction.sh
```

## Schedule (cron)
Run at 11:59pm daily:
```bash
crontab -e
```
Add:
```cron
59 23 * * * /path/to/daily-prediction.sh >> /tmp/openclaw-daily.log 2>&1
```

## Notes
- Requires `openclaw` CLI in PATH.
- If CLI is missing, placeholders remain.


## openclaw CLI dependency
The `daily-prediction.sh` script optionally uses an `openclaw` CLI to generate text. If the CLI is not available, the script creates a safe placeholder file and you can have your agent fill it in.

# Health Checks (Cron)

## What it checks
- Gateway health (port 18799)
- Core MD files present in workspace root
- Backup folder presence
- Config + workspace directories exist

## Run manually
```bash
chmod +x health-check.sh
./health-check.sh
```

## Schedule (cron, every 6 hours)
```bash
crontab -e
```
Add:
```cron
0 */6 * * * /path/to/health-check.sh >> /tmp/openclaw-health.log 2>&1
```

## Notes
- If gateway is not running, check Docker or OpenClaw service.
- Backups are expected in `~/openclaw-backups` (created by the installer).

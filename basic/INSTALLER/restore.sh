#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
BACKUP_BASE="$HOME/openclaw-backups"

echo "Workspace: $WORKSPACE_DIR"
echo "Backups in: $BACKUP_BASE"
echo

if [ ! -d "$BACKUP_BASE" ]; then
  echo "No backups found."
  exit 1
fi

echo "Available backups (newest first):"
ls -1t "$BACKUP_BASE" 2>/dev/null || { echo "No backups found."; exit 1; }

echo
read -r -p "Enter backup folder name to restore: " CHOICE

if [ -z "$CHOICE" ] || [ ! -d "$BACKUP_BASE/$CHOICE" ]; then
  echo "Invalid choice: $CHOICE"
  exit 1
fi

echo
echo "Restoring from $BACKUP_BASE/$CHOICE to $WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR"
cp -R "$BACKUP_BASE/$CHOICE/." "$WORKSPACE_DIR/"
echo "Restore complete."

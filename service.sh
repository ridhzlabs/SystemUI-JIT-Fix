#!/system/bin/sh
# SystemUI JIT Crash Fix - service.sh (runs as root on boot via KernelSU Next)
# Re-applies "speed" AOT compile to SystemUI so the ART JIT compiler never
# touches the method that crashes its inliner (SIGSEGV fault addr 0x30).
# Safe to run repeatedly: skips work when status is already "speed".

MODDIR=${0%/*}
LOGFILE="$MODDIR/fix.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

# Wait for boot to complete (max ~5 minutes)
for i in $(seq 1 60); do
  if [ "$(getprop sys.boot_completed)" = "1" ]; then
    break
  fi
  sleep 5
done

# Give the package manager a moment to settle
sleep 20

STATUS=$(dumpsys package com.android.systemui 2>/dev/null | grep -m 1 -o '\[status=[a-z-]*\]' | head -1)
log "current compile status: $STATUS"

case "$STATUS" in
  *speed*)
    log "already speed, nothing to do"
    exit 0
    ;;
esac

log "compiling com.android.systemui with speed filter..."
cmd package compile -m speed -f com.android.systemui >> "$LOGFILE" 2>&1
log "compile exit code: $?"

NEWSTATUS=$(dumpsys package com.android.systemui 2>/dev/null | grep -m 1 -o '\[status=[a-z-]*\]' | head -1)
log "new compile status: $NEWSTATUS"
exit 0

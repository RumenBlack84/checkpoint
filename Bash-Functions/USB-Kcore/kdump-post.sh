#!/bin/sh
# kdump post-hook for Gaia/RHEL: write vmcore straight to USB (by UUID),
# avoiding local disk usage. Uses makedumpfile (compressed) if available,
# otherwise falls back to copying any local crash dir.

set -eu

# ---- CONFIG: adjust for your environment -----------------------------------
USB_UUID="33c4f0cd-d4f1-4f72-8a52-74445a1dec9b" # set from: blkid /dev/sdX1
USB_MNT="/mnt/kdumpusb"                         # temp mount point
DEST_SUBDIR="kdumps"                            # subdir on USB for dumps
GZIP_LEVEL="3"                                  # fallback gzip level if used
# ----------------------------------------------------------------------------

LOG="/var/log/crash/kdump-post.log"
log() { echo "[$(date -u +%F %T)] $*" >>"$LOG"; }

SUCCESS="${1:-1}"

# Read local landing zone (we won't rely on it, but use as fallback)
COREPATH="$(awk '/^[[:space:]]*path[[:space:]]+/ {print $2}' /etc/kdump.conf 2>/dev/null || true)"
[ -n "${COREPATH}" ] || COREPATH="/var/crash"

TS="$(date -u +%Y-%m-%d-%H%M%S)"
HOST="$(hostname 2>/dev/null || echo host)"
USB_DEV="/dev/disk/by-uuid/${USB_UUID}"

# Wait for USB node to appear (kdump kernel init can be slow to enumerate)
mkdir -p "${USB_MNT}"
for _ in $(seq 1 60); do
  [ -e "${USB_DEV}" ] && break
  sleep 1
done
if [ ! -e "${USB_DEV}" ]; then
  log "ERROR: ${USB_DEV} not found; no USB in kdump kernel."
  exit 0
fi

# Mount USB
if ! mount -t auto "${USB_DEV}" "${USB_MNT}"; then
  log "ERROR: failed to mount ${USB_DEV} at ${USB_MNT}"
  exit 0
fi

DST="${USB_MNT}/${DEST_SUBDIR}/${HOST}-${TS}"
mkdir -p "${DST}"

# Prefer DIRECT stream from /proc/vmcore using makedumpfile
if [ -r /proc/vmcore ]; then
  if command -v makedumpfile >/dev/null 2>&1; then
    # Compressed, filtered vmcore written directly to USB
    log "Streaming /proc/vmcore → ${DST}/vmcore (makedumpfile -c -d 31)…"
    if makedumpfile -c --message-level 1 -d 31 /proc/vmcore "${DST}/vmcore"; then
      sync
      umount "${USB_MNT}" || log "WARN: umount failed."
      log "Direct makedumpfile capture complete to ${DST}/vmcore"
      exit 0
    else
      log "WARN: makedumpfile direct capture failed; will try fallback."
    fi
  else
    # As a last resort: raw gzip stream (no page filtering)
    log "makedumpfile not found; gzipping raw /proc/vmcore → ${DST}/vmcore.gz (gzip -${GZIP_LEVEL})…"
    if gzip -c -"${GZIP_LEVEL}" </proc/vmcore >"${DST}/vmcore.gz"; then
      sync
      umount "${USB_MNT}" || log "WARN: umount failed."
      log "Direct gzip capture complete to ${DST}/vmcore.gz"
      exit 0
    else
      log "WARN: gzip of raw /proc/vmcore failed; will try fallback."
    fi
  fi
else
  log "INFO: /proc/vmcore not present/accessible; skipping direct capture."
fi

# Fallback: copy the most recent local crash dir if it exists
LAST_DIR="$(ls -1dt "${COREPATH}"/* 2>/dev/null | head -n1 || true)"
if [ -n "${LAST_DIR}" ]; then
  log "Fallback copying local crash dir ${LAST_DIR} → ${DST}/"
  cp -a "${LAST_DIR}/." "${DST}/" || log "WARN: fallback cp returned nonzero."
  sync
else
  log "No local crash directory found under ${COREPATH}; nothing to fallback copy."
fi

umount "${USB_MNT}" || log "WARN: umount failed."
log "Post-hook finished."
exit 0

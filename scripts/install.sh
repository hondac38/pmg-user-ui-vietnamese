#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE="${PROJECT_DIR}/locale/pmg-lang-vi.js"
TARGET="/usr/share/pmg-i18n/pmg-lang-vi.js"

BACKUP_ROOT="/var/backups/pmg-user-ui-vietnamese"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

log() {
    printf '[INFO] %s\n' "$1"
}

ok() {
    printf '[OK]   %s\n' "$1"
}

die() {
    printf '[FAIL] %s\n' "$1" >&2
    exit 1
}

[[ "${EUID}" -eq 0 ]] \
    || die "Phải chạy bằng quyền root."

[[ -s "${SOURCE}" ]] \
    || die "Không tìm thấy locale: ${SOURCE}"

PMG_API_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-api 2>/dev/null || true
)"

PMG_GUI_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-gui 2>/dev/null || true
)"

PMG_I18N_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-i18n 2>/dev/null || true
)"

log "pmg-api  : ${PMG_API_VERSION}"
log "pmg-gui  : ${PMG_GUI_VERSION}"
log "pmg-i18n : ${PMG_I18N_VERSION}"

if [[ "${PMG_API_VERSION}" != 9.1.2* ]]; then
    die "Locale hiện được kiểm thử với PMG 9.1.2."
fi

mkdir -p "${BACKUP_DIR}"
mkdir -p "$(dirname "${TARGET}")"

if [[ -f "${TARGET}" ]]; then
    cp -a "${TARGET}" \
      "${BACKUP_DIR}/pmg-lang-vi.js"
fi

install \
  -o root \
  -g root \
  -m 0644 \
  "${SOURCE}" \
  "${TARGET}"

SOURCE_SHA="$(
    sha256sum "${SOURCE}" | awk '{print $1}'
)"

TARGET_SHA="$(
    sha256sum "${TARGET}" | awk '{print $1}'
)"

[[ "${SOURCE_SHA}" == "${TARGET_SHA}" ]] \
    || die "Checksum locale sau khi cài không khớp."

grep -Fq \
  '"640367448":["Khu vực cách ly thư rác"]' \
  "${TARGET}" \
  || die "Không tìm thấy bản dịch Spam Quarantine."

grep -Fq \
  '"1218201859":["Thư đã chọn"]' \
  "${TARGET}" \
  || die "Không tìm thấy bản dịch Selected Mail."

systemctl restart pmgproxy

ok "Đã cài locale tiếng Việt cho User Quarantine UI."
log "Backup: ${BACKUP_DIR}"

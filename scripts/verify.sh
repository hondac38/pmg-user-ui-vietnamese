#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE="${PROJECT_DIR}/locale/pmg-lang-vi.js"
TARGET="/usr/share/pmg-i18n/pmg-lang-vi.js"
PROXMOXLIB="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

PASS=0
FAIL=0

pass() {
    PASS=$((PASS + 1))
    printf '[PASS] %s\n' "$1"
}

fail() {
    FAIL=$((FAIL + 1))
    printf '[FAIL] %s\n' "$1"
}

if [[ -s "${TARGET}" ]]; then
    pass "pmg-lang-vi.js đã được cài"
else
    fail "Không tìm thấy pmg-lang-vi.js"
fi

if [[ -f "${SOURCE}" && -f "${TARGET}" ]] &&
   cmp -s "${SOURCE}" "${TARGET}"
then
    pass "Locale đúng checksum/nội dung project"
else
    fail "Locale runtime không khớp project"
fi

if grep -Fq \
    '"640367448":["Khu vực cách ly thư rác"]' \
    "${TARGET}"
then
    pass "Spam Quarantine có bản dịch tiếng Việt"
else
    fail "Thiếu bản dịch Spam Quarantine"
fi

if grep -Fq \
    '"902538149":["Chi tiết điểm thư rác"]' \
    "${TARGET}"
then
    pass "Spam Score Breakdown có bản dịch tiếng Việt"
else
    fail "Thiếu bản dịch Spam Score Breakdown"
fi

if grep -Fq 'Tiếng Việt' "${PROXMOXLIB}"; then
    fail "Admin Language Selector vẫn bị sửa"
else
    pass "Admin Language Selector giữ nguyên"
fi

echo
echo "========================================"
echo " KẾT QUẢ"
echo "========================================"
echo "PASS : ${PASS}"
echo "FAIL : ${FAIL}"

[[ "${FAIL}" -eq 0 ]]

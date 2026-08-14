#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOCALE_SOURCE="${PROJECT_DIR}/locale/pmg-lang-vi.js"
LOCALE_TARGET="/usr/share/pmg-i18n/pmg-lang-vi.js"

PMGPROXY="/usr/share/perl5/PMG/Service/pmgproxy.pm"
PMGMANAGER="/usr/share/javascript/pmg-gui/js/pmgmanagerlib.js"

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

echo "============================================================"
echo " PMG User UI Vietnamese - Verification"
echo "============================================================"
echo

if [[ -s "${LOCALE_TARGET}" ]]; then
    pass "pmg-lang-vi.js đã được cài"
else
    fail "Không tìm thấy pmg-lang-vi.js"
fi

if [[ -f "${LOCALE_SOURCE}" ]] &&
   [[ -f "${LOCALE_TARGET}" ]] &&
   cmp -s "${LOCALE_SOURCE}" "${LOCALE_TARGET}"
then
    pass "Locale runtime khớp với project"
else
    fail "Locale runtime không khớp project"
fi

if grep -Fq \
    '"640367448":["Khu vực cách ly thư rác"]' \
    "${LOCALE_TARGET}"
then
    pass "Có bản dịch Spam Quarantine"
else
    fail "Thiếu bản dịch Spam Quarantine"
fi

if grep -Fq \
    '"902538149":["Chi tiết điểm thư rác"]' \
    "${LOCALE_TARGET}"
then
    pass "Có bản dịch Spam Score Breakdown"
else
    fail "Thiếu bản dịch Spam Score Breakdown"
fi

if grep -Fq \
    "\$lang = 'vi' if \$quarantine;" \
    "${PMGPROXY}"
then
    pass "User Quarantine được ép locale vi"
else
    fail "Chưa ép locale vi cho User Quarantine"
fi

if perl -c "${PMGPROXY}" >/dev/null 2>&1; then
    pass "pmgproxy.pm syntax hợp lệ"
else
    fail "pmgproxy.pm syntax lỗi"
fi

if python3 - "${PMGMANAGER}" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

start = s.find("Ext.define('PMG.QuarantineView'")
if start == -1:
    sys.exit(1)

end = s.find("\nExt.define(", start + 1)
if end == -1:
    end = len(s)

block = s[start:end]

sys.exit(1 if "reference: 'languageButton'" in block else 0)
PY
then
    pass "User Quarantine không còn Language menu"
else
    fail "User Quarantine vẫn còn Language menu"
fi

if systemctl is-active --quiet pmgproxy; then
    pass "pmgproxy đang hoạt động"
else
    fail "pmgproxy không hoạt động"
fi

echo
echo "============================================================"
echo " KẾT QUẢ"
echo "============================================================"
echo "PASS : ${PASS}"
echo "FAIL : ${FAIL}"

if [[ "${FAIL}" -eq 0 ]]; then
    echo
    echo "[SUCCESS] PMG User UI Vietnamese hoạt động bình thường."
    exit 0
fi

exit 1

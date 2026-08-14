#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOCALE_SOURCE="${PROJECT_DIR}/locale/pmg-lang-vi.js"
LOCALE_TARGET="/usr/share/pmg-i18n/pmg-lang-vi.js"

PMGPROXY="/usr/share/perl5/PMG/Service/pmgproxy.pm"
PMGMANAGER="/usr/share/javascript/pmg-gui/js/pmgmanagerlib.js"

BACKUP_ROOT="/var/backups/pmg-user-ui-vietnamese"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

DRY_RUN=0

declare -a PATCH_TARGETS=(
    "pmg-9.1.2-quarantine-force-vi.patch|${PMGPROXY}"
    "pmg-gui-5.2.2-quarantine-hide-language.patch|${PMGMANAGER}"
)

info() {
    printf '[INFO] %s\n' "$1"
}

ok() {
    printf '[OK]   %s\n' "$1"
}

warn() {
    printf '[WARN] %s\n' "$1"
}

die() {
    printf '[FAIL] %s\n' "$1" >&2
    exit 1
}

usage() {
    cat <<USAGE
Usage:
    $0
    $0 --dry-run

Options:
    --dry-run   Chỉ kiểm tra khả năng cài đặt, không thay đổi hệ thống.
USAGE
}

for arg in "$@"; do
    case "${arg}" in
        --dry-run)
            DRY_RUN=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Tham số không hợp lệ: ${arg}"
            ;;
    esac
done

[[ "${EUID}" -eq 0 ]] \
    || die "Installer phải chạy bằng quyền root."

[[ -s "${LOCALE_SOURCE}" ]] \
    || die "Thiếu locale: ${LOCALE_SOURCE}"

PMG_API_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-api 2>/dev/null || true
)"

PMG_GUI_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-gui 2>/dev/null || true
)"

PMG_I18N_VERSION="$(
    dpkg-query -W -f='${Version}' pmg-i18n 2>/dev/null || true
)"

info "pmg-api  : ${PMG_API_VERSION}"
info "pmg-gui  : ${PMG_GUI_VERSION}"
info "pmg-i18n : ${PMG_I18N_VERSION}"

[[ "${PMG_API_VERSION}" == 9.1.2* ]] \
    || die "Chỉ hỗ trợ pmg-api 9.1.2."

[[ "${PMG_GUI_VERSION}" == 5.2.2* ]] \
    || die "Chỉ hỗ trợ pmg-gui 5.2.2."

[[ "${PMG_I18N_VERSION}" == 3.9.0* ]] \
    || die "Chỉ hỗ trợ pmg-i18n 3.9.0."

info "Kiểm tra patch."

for mapping in "${PATCH_TARGETS[@]}"; do
    patch_name="${mapping%%|*}"
    target="${mapping#*|}"
    patch_file="${PROJECT_DIR}/patches/${patch_name}"

    [[ -s "${patch_file}" ]] \
        || die "Thiếu patch: ${patch_file}"

    [[ -f "${target}" ]] \
        || die "Không tìm thấy target: ${target}"

    if patch \
        --batch \
        --forward \
        --dry-run \
        "${target}" \
        < "${patch_file}" >/dev/null 2>&1
    then
        ok "Có thể áp dụng: ${patch_name}"
    elif patch \
        --batch \
        --reverse \
        --dry-run \
        "${target}" \
        < "${patch_file}" >/dev/null 2>&1
    then
        warn "Patch đã được áp dụng: ${patch_name}"
    else
        die "Patch không tương thích: ${patch_name}"
    fi
done

if [[ "${DRY_RUN}" -eq 1 ]]; then
    ok "Dry-run hoàn tất; hệ thống chưa bị thay đổi."
    exit 0
fi

mkdir -p "${BACKUP_DIR}"

cp -a "${PMGPROXY}" \
    "${BACKUP_DIR}/pmgproxy.pm"

cp -a "${PMGMANAGER}" \
    "${BACKUP_DIR}/pmgmanagerlib.js"

if [[ -f "${LOCALE_TARGET}" ]]; then
    cp -a "${LOCALE_TARGET}" \
        "${BACKUP_DIR}/pmg-lang-vi.js"
fi

info "Backup: ${BACKUP_DIR}"

for mapping in "${PATCH_TARGETS[@]}"; do
    patch_name="${mapping%%|*}"
    target="${mapping#*|}"
    patch_file="${PROJECT_DIR}/patches/${patch_name}"

    if patch \
        --batch \
        --forward \
        --dry-run \
        "${target}" \
        < "${patch_file}" >/dev/null 2>&1
    then
        patch \
            --batch \
            --forward \
            "${target}" \
            < "${patch_file}"

        ok "Đã áp dụng: ${patch_name}"
    else
        warn "Bỏ qua patch đã tồn tại: ${patch_name}"
    fi
done

install \
    -o root \
    -g root \
    -m 0644 \
    "${LOCALE_SOURCE}" \
    "${LOCALE_TARGET}"

ok "Đã cài pmg-lang-vi.js"

perl -c "${PMGPROXY}" >/dev/null \
    || die "pmgproxy.pm lỗi syntax."

systemctl restart pmgproxy

systemctl is-active --quiet pmgproxy \
    || die "pmgproxy không hoạt động."

ok "pmgproxy đang hoạt động."

"${PROJECT_DIR}/scripts/verify.sh"

echo
ok "Cài đặt PMG User UI Vietnamese hoàn tất."
info "Backup: ${BACKUP_DIR}"

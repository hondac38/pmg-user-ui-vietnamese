__proxmox_i18n_msgcat__ = {
    "640367448":["Khu vực cách ly thư rác"],
    "107626267":["Danh sách tin cậy"],
    "2125650686":["Danh sách chặn"],
    "949874714":["Trợ giúp"],
    "1218201859":["Thư đã chọn"],

    "410269077":["Người gửi"],
    "544810223":["Chủ đề"],
    "1727539088":["Người nhận"],
    "1230354862":["Cho phép nhận"],
    "1469573738":["Xóa"],

    "878327704":["Không có tệp đính kèm"],
    "902538149":["Chi tiết điểm thư rác"],
    "49989660":["Tên kiểm tra"],
    "2011890229":["Điểm"],
    "1725856265":["Mô tả"],

    "1101461821":["Từ ngày"],
    "1659567087":["Đến ngày"],
    "1179034313":["Tìm kiếm"],
    "2094461579":["Người gửi/Chủ đề"],
    "995259257":["Ngày"],
    "501706684":["Kích thước (KB)"],
    "1608836100":["Thời gian"],

    "675098582":["Tải thư này dưới dạng .eml"],
    "498946337":["Tệp đính kèm"],

    "1702099076":["Người gửi"],
    "443800475":["Ngôn ngữ"],
    "750979128":["Mật khẩu"],
    "1517138453":["Tên người dùng"],

    "1431953702":["Yêu cầu liên kết quản lý thư cách ly"],
    "1572133275":["Email của bạn"]
};

__proxmox_i18n_plurals_msgcat__ = {};

function fnv31a(text) {
    var len = text.length;
    var hval = 0x811c9dc5;

    for (var i = 0; i < len; i++) {
        var c = text.charCodeAt(i);
        hval ^= c;
        hval +=
            (hval << 1) +
            (hval << 4) +
            (hval << 7) +
            (hval << 8) +
            (hval << 24);
    }

    hval &= 0x7fffffff;
    return hval;
}

function gettext(buf) {
    var digest = fnv31a(buf);
    var data = __proxmox_i18n_msgcat__[digest];

    if (!data) {
        return buf;
    }

    return data[0] || buf;
}

function ngettext(singular, plural, n) {
    const msg_idx = Number((n >= 2));
    const digest = fnv31a(singular);
    const translation = __proxmox_i18n_plurals_msgcat__[digest];

    if (!translation || msg_idx >= translation.length) {
        return n === 1 ? singular : plural;
    }

    return translation[msg_idx];
}

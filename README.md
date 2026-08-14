# PMG User UI Vietnamese

Bộ Việt hóa tiếng Việt dành riêng cho **giao diện người dùng cuối (End-user Quarantine UI)** của **Proxmox Mail Gateway (PMG)**.

Project tập trung Việt hóa giao diện mà người dùng truy cập từ liên kết **Spam Quarantine**, không thay đổi ngôn ngữ mặc định của toàn bộ giao diện quản trị PMG.

> Phiên bản hiện tại: **v0.1.1**

---

## Mục tiêu

PMG cung cấp giao diện Quarantine riêng cho người dùng cuối để kiểm tra và xử lý các thư bị đưa vào khu vực cách ly.

Project này có các mục tiêu:

- Người dùng mở liên kết Quarantine sẽ tự động sử dụng tiếng Việt.
- Không yêu cầu người dùng tự chọn ngôn ngữ.
- Ẩn menu `Language` khỏi giao diện User Quarantine.
- Chỉ tác động đến giao diện `/quarantine`.
- Không ép giao diện quản trị PMG của `root` hoặc administrator sang tiếng Việt.
- Giữ phạm vi thay đổi nhỏ để dễ kiểm tra, backup và nâng cấp.

---

## Phạm vi Việt hóa

Project tập trung vào các thành phần người dùng thường xuyên sử dụng trong Spam Quarantine.

| English | Tiếng Việt |
|---|---|
| Spam Quarantine | Khu vực cách ly thư rác |
| Welcomelist | Danh sách tin cậy |
| Blocklist | Danh sách chặn |
| Selected Mail | Thư đã chọn |
| Since | Từ ngày |
| Until | Đến ngày |
| Search | Tìm kiếm |
| Sender | Người gửi |
| Subject | Chủ đề |
| Receiver | Người nhận |
| Sender/Subject | Người gửi/Chủ đề |
| Score | Điểm |
| Time | Thời gian |
| Deliver | Cho phép nhận |
| Delete | Xóa |
| Attachments | Tệp đính kèm |
| No Attachments | Không có tệp đính kèm |
| Spam Score Breakdown | Chi tiết điểm thư rác |
| Test Name | Tên kiểm tra |
| Description | Mô tả |
| Help | Trợ giúp |

Một số tên rule và mô tả kỹ thuật do SpamAssassin cung cấp có thể vẫn hiển thị bằng tiếng Anh.

Project không thay đổi cơ chế chấm điểm hoặc xử lý spam của SpamAssassin.

---

## Những phần không được Việt hóa

Project **không phải** bộ Việt hóa toàn bộ Proxmox Mail Gateway.

Không chủ động Việt hóa:

- Dashboard quản trị.
- Configuration.
- Mail Proxy.
- Spam Detector dành cho administrator.
- Virus Detector.
- User Management.
- Cluster.
- Subscription.
- Backup/Restore.
- Certificates.
- Tracking Center.
- API/backend PMG.

Giao diện root/admin vẫn sử dụng ngôn ngữ mặc định.

---

## Cơ chế hoạt động

Project sử dụng ba thành phần chính.

### 1. Locale tiếng Việt

File:

    locale/pmg-lang-vi.js

được cài vào:

    /usr/share/pmg-i18n/pmg-lang-vi.js

File này chứa các chuỗi dịch tiếng Việt dành cho giao diện User Quarantine.

### 2. Tự động ép locale `vi` cho User Quarantine

Patch:

    patches/pmg-9.1.2-quarantine-force-vi.patch

được áp dụng lên:

    /usr/share/perl5/PMG/Service/pmgproxy.pm

Khi truy cập:

    /quarantine

PMG sẽ tự động sử dụng locale:

    vi

Người dùng không cần tự chỉnh cookie hoặc chọn ngôn ngữ.

### 3. Ẩn Language menu trong User Quarantine

Patch:

    patches/pmg-gui-5.2.2-quarantine-hide-language.patch

được áp dụng lên:

    /usr/share/javascript/pmg-gui/js/pmgmanagerlib.js

Menu `Language` chỉ được ẩn trong User Quarantine.

Giao diện quản trị root/admin không bị ép sang tiếng Việt.

---

## Phiên bản đã kiểm thử

| Thành phần | Phiên bản |
|---|---:|
| Proxmox Mail Gateway | 9.1.2 |
| pmg-api | 9.1.2 |
| pmg-gui | 5.2.2 |
| pmg-i18n | 3.9.0 |
| Debian | 13 Trixie |

Các patch phụ thuộc phiên bản PMG và PMG GUI.

Không nên ép cài trên phiên bản khác nếu chưa kiểm tra tương thích.

---

## Cài đặt

Clone repository:

    cd /root
    git clone https://github.com/hondac38/pmg-user-ui-vietnamese.git
    cd pmg-user-ui-vietnamese

Khuyến nghị checkout release:

    git checkout v0.1.1

Kiểm tra tag:

    git describe --tags --exact-match HEAD

---

## Kiểm tra trước khi cài

Chạy dry-run:

    ./scripts/install.sh --dry-run

Dry-run chỉ kiểm tra khả năng áp dụng patch, không thay đổi hệ thống.

Nếu không có lỗi, tiếp tục cài đặt.

---

## Cài đặt thật

Chạy:

    ./scripts/install.sh

Installer sẽ:

1. Kiểm tra phiên bản PMG.
2. Kiểm tra các file cần thiết.
3. Kiểm tra khả năng áp dụng patch.
4. Backup file hệ thống trước khi sửa.
5. Cài `pmg-lang-vi.js`.
6. Patch `pmgproxy.pm`.
7. Patch `pmgmanagerlib.js`.
8. Kiểm tra syntax.
9. Restart `pmgproxy`.
10. Chạy verifier.

Backup được lưu tại:

    /var/backups/pmg-user-ui-vietnamese/

---

## Xác minh sau khi cài

Chạy:

    ./scripts/verify.sh

Kết quả kiểm thử hiện tại:

    PASS : 8
    FAIL : 0

Các kiểm tra gồm:

- `pmg-lang-vi.js` đã được cài.
- Locale runtime khớp project.
- Có bản dịch Spam Quarantine.
- Có bản dịch Spam Score Breakdown.
- User Quarantine được ép locale `vi`.
- `pmgproxy.pm` syntax hợp lệ.
- User Quarantine không còn Language menu.
- `pmgproxy` đang hoạt động.

---

## Kiểm tra thực tế trên trình duyệt

Mở một Quarantine Link hợp lệ do PMG gửi cho người dùng.

Ví dụ:

    https://pmg.example.com:8006/quarantine?ticket=...

Giao diện phải tự động hiển thị tiếng Việt.

Người dùng không cần:

- chọn Vietnamese;
- thay đổi Language;
- chỉnh cookie;
- đăng nhập bằng tài khoản root.

---

## Ảnh hưởng đến Admin UI

Giao diện administrator:

    https://pmg.example.com:8006/

không bị ép locale `vi`.

Giao diện End-user Quarantine:

    https://pmg.example.com:8006/quarantine

được tự động sử dụng tiếng Việt.

Đây là chủ đích của project: **Việt hóa giao diện người nhận thư, không Việt hóa toàn bộ PMG Admin UI.**

---

## Cấu trúc repository

    pmg-user-ui-vietnamese/
    ├── locale/
    │   └── pmg-lang-vi.js
    ├── patches/
    │   ├── pmg-9.1.2-quarantine-force-vi.patch
    │   └── pmg-gui-5.2.2-quarantine-hide-language.patch
    ├── scripts/
    │   ├── install.sh
    │   └── verify.sh
    ├── .gitignore
    ├── README.md
    └── VERSION

---

## Sau khi nâng cấp PMG

Các package PMG có thể ghi đè các file đã patch.

Sau khi nâng cấp, chạy:

    ./scripts/verify.sh

Nếu verifier báo lỗi, không nên ép patch cũ.

Kiểm tra phiên bản:

    pmgversion -v

Sau đó xác nhận project đã hỗ trợ phiên bản PMG mới hay chưa.

---

## Cập nhật project

Lấy tag mới:

    git fetch --tags

Xem danh sách release:

    git tag --sort=-version:refname

Checkout release mong muốn:

    git checkout v0.1.1

Trước khi cài lại:

    ./scripts/install.sh --dry-run

---

## Repository

GitHub:

    https://github.com/hondac38/pmg-user-ui-vietnamese

Maintainer:

    hondac38

---

## Trạng thái v0.1.1

    Installer dry-run : PASS
    Verification      : PASS 8
    Verification FAIL : 0
    Target UI         : End-user Quarantine
    Locale            : Vietnamese
    Admin UI forced VI: No
    Language menu     : Hidden in User Quarantine

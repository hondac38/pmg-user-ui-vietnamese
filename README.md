# PMG User UI Vietnamese

Bộ Việt hóa tiếng Việt dành riêng cho giao diện người dùng Spam Quarantine của Proxmox Mail Gateway.

## Mục tiêu

Chỉ Việt hóa giao diện dành cho người dùng cuối khi truy cập khu vực quản lý thư cách ly.

Không Việt hóa toàn bộ giao diện quản trị PMG.

## Phạm vi

Bao gồm:

- Spam Quarantine → Khu vực cách ly thư rác
- Welcomelist → Danh sách tin cậy
- Blocklist → Danh sách chặn
- Selected Mail → Thư đã chọn
- Since → Từ ngày
- Until → Đến ngày
- Search → Tìm kiếm
- Sender / Subject / Receiver
- Deliver / Delete
- Attachments
- Spam Score Breakdown
- Score / Description / Test Name

Một số mô tả rule SpamAssassin vẫn được giữ nguyên tiếng Anh.

## Phiên bản kiểm thử

- Proxmox Mail Gateway: 9.1.2
- pmg-api: 9.1.2
- pmg-gui: 5.2.2
- pmg-i18n: 3.9.0
- Debian: 13 Trixie

## Cài đặt

Chạy:

    chmod +x scripts/install.sh
    ./scripts/install.sh

## Kiểm tra

Chạy:

    ./scripts/verify.sh

## Cơ chế

Locale tiếng Việt được cài tại:

    /usr/share/pmg-i18n/pmg-lang-vi.js

Project không sửa Language Selector chung của giao diện quản trị.

## Phạm vi ảnh hưởng

Mục tiêu của project là Việt hóa giao diện User Quarantine.

Giao diện quản trị root/admin vẫn giữ nguyên ngôn ngữ mặc định.

## Lưu ý

Locale `vi` được PMG nhận diện thông qua `PMGLangCookie=vi`.

Một số chuỗi mô tả rule SpamAssassin có thể vẫn hiển thị tiếng Anh vì đây là nội dung mô tả của rule, không phải chuỗi giao diện PMG.

Sau khi nâng cấp `pmg-gui`, `pmg-i18n` hoặc PMG, nên chạy lại:

    ./scripts/verify.sh


# 🪟 Win-Docker Manager

> **Cài đặt, quản lý và gỡ bỏ Windows trên Docker chỉ với một script duy nhất - Tối ưu cho Linux Mint 22.x**

[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Linux Mint](https://img.shields.io/badge/Linux%20Mint-22.x-87CF3E.svg)](https://linuxmint.com/)
[![Docker](https://img.shields.io/badge/Docker-required-2496ED.svg)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Powered by dockur/windows](https://img.shields.io/badge/Powered%20by-dockur%2Fwindows-blue.svg)](https://github.com/dockur/windows)

**Win-Docker Manager** là một bash script **all-in-one** giúp bạn cài đặt Windows trong container Docker trên Linux một cách **siêu nhanh, siêu nhẹ, siêu dễ**. Không cần dual-boot, không cần VirtualBox/VMware nặng nề - chỉ cần Docker và một trình duyệt web.

Đặc biệt phù hợp cho ai cần chạy các phần mềm Windows-only như **UltraViewer, TeamViewer, AnyDesk, các app, phần mềm kế toán MISA/FAST**... trên Linux mà vẫn muốn máy nhẹ nhàng.

---

## 📑 Mục lục

- [✨ Điểm mạnh nổi bật](#-điểm-mạnh-nổi-bật)
- [🎯 Dành cho ai?](#-dành-cho-ai)
- [📋 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [🚀 Cài đặt nhanh](#-cài-đặt-nhanh)
- [📦 Danh sách phiên bản Windows hỗ trợ](#-danh-sách-phiên-bản-windows-hỗ-trợ)
- [⚙️ Cấu hình tài nguyên thông minh](#️-cấu-hình-tài-nguyên-thông-minh)
- [🎮 5 Alias siêu tiện](#-5-alias-siêu-tiện)
- [🗑️ Gỡ cài đặt - 3 mức độ](#️-gỡ-cài-đặt---3-mức-độ)
- [📊 So sánh với các giải pháp khác](#-so-sánh-với-các-giải-pháp-khác)
- [💡 Use case thực tế](#-use-case-thực-tế)
- [🔧 Khắc phục sự cố](#-khắc-phục-sự-cố)
- [📝 Đóng góp](#-đóng-góp)
- [📄 License](#-license)
- [🙏 Lời cảm ơn](#-lời-cảm-ơn)

---

## ✨ Điểm mạnh nổi bật

### 🎯 **All-in-One trong một file duy nhất**
Một script `win-docker-manager.sh` lo trọn mọi việc: cài Docker → tải Windows → cấu hình → khởi chạy → quản lý → gỡ bỏ. **Không cần nhớ nhiều lệnh, không cần copy-paste nhiều file**.

### 🧠 **Tự động phát hiện cấu hình máy**
Script tự dò RAM và CPU của bạn rồi gợi ý cấu hình tối ưu:
- Máy 4GB RAM → cấp 2G cho Windows
- Máy 8GB RAM → cấp 3G cho Windows
- Máy 16GB RAM → cấp 4G cho Windows
- Máy >16GB RAM → cấp 6G cho Windows

**Không lo cấp sai làm treo máy.**

### 📦 **18 phiên bản Windows chính thức + ISO tùy biến**
Danh sách phiên bản được đồng bộ chính xác với repo [dockur/windows](https://github.com/dockur/windows), từ **Windows 2000 (0.4GB)** đến **Windows Server 2025 (7.6GB)**, và đặc biệt hỗ trợ nhập URL ISO tùy biến cho các bản như **Tiny11/Tiny10/ReviOS**.

### ⚡ **5 Alias bật/tắt siêu nhanh**
Sau khi cài, script tự thêm 5 alias vào `~/.bashrc` và **tự áp dụng ngay** cho phiên hiện tại - không cần `source` thủ công:

```bash
win-init      # ▶ Lần đầu - khởi tạo + tải Windows
win-start     # ▶ Bật Windows khi cần dùng
win-stop      # ⏹ Tắt hoàn toàn, giải phóng 100% RAM
win-status    # 📊 Xem RAM/CPU đang dùng
win-logs      # 📜 Xem log nếu lỗi
```

### 🔋 **`restart: "no"` - Không ngốn RAM ngầm**
Container được cấu hình **KHÔNG tự khởi động** khi bạn bật máy Linux. Chỉ chạy khi bạn gõ `win-start`, tắt là giải phóng **100% RAM** ngay. Đây là điểm khác biệt lớn so với cài Windows trên VirtualBox/VMware (thường để tự chạy ngầm gây nặng máy).

### 🚀 **Tự động phát hiện và bật KVM**
Nếu CPU hỗ trợ ảo hóa (VT-x/AMD-V), script tự bật KVM trong `docker-compose.yml` → Windows chạy **nhanh gấp 5-10 lần** so với chế độ emulation thuần. Nếu không có KVM, script vẫn cấu hình được nhưng cảnh báo rõ ràng.

### 🌐 **Truy cập qua trình duyệt - Không cần phần mềm RDP**
Mở Chrome/Firefox → vào `http://localhost:8006` → thấy ngay desktop Windows. Đơn giản như xem YouTube. Có thể truy cập từ máy khác trong LAN.

### 🔒 **Idempotent & An toàn**
- Chạy lại script nhiều lần **không gây lỗi** - tự skip bước đã làm
- **Tự backup** `docker-compose.yml` và `.bashrc` trước khi sửa
- **2 lớp xác nhận** khi gỡ cài đặt (chọn mức + gõ `YES`)
- Có **kiểm tra tàn dư** sau khi gỡ

### 🗑️ **Gỡ cài đặt sạch tuyệt đối - 3 mức độ**
Không như nhiều script khác chỉ xóa nửa vời, Win-Docker Manager có **3 mức gỡ**:
- **Nhẹ**: Chỉ xóa Windows (giữ Docker dùng việc khác)
- **Trung bình**: Mức 1 + dọn sạch toàn bộ Docker data
- **Hoàn toàn**: Mức 2 + gỡ luôn Docker Engine, trả máy về trạng thái sạch

### 🎨 **UI/UX tốt nhất trong dòng script bash**
- Menu màu sắc, icon emoji trực quan
- Banner ASCII đẹp mắt
- Tiến trình rõ ràng từng bước (`[1/5]`, `[2/5]`...)
- Thông báo phân loại bằng màu: `[INFO]` xanh dương, `[OK]` xanh lá, `[WARN]` vàng, `[ERR]` đỏ
- Tự tính dung lượng đã giải phóng sau khi gỡ

### 🌏 **100% tiếng Việt**
Toàn bộ menu, thông báo, hướng dẫn đều bằng tiếng Việt - dễ hiểu cho người mới bắt đầu.

---

## 🎯 Dành cho ai?

✅ **Người dùng Linux Mint cần chạy app Windows-only** (UltraViewer, MISA, FAST Accounting, Internet, game cũ...)
✅ **Lập trình viên cần test app trên Windows** mà không muốn dual-boot
✅ **Người mới học Linux** muốn giữ một "góc Windows" để dùng khi cần
✅ **Sysadmin muốn chạy Windows Server** trong container để test
✅ **Người dùng máy yếu** (RAM 4-8GB) - script tối ưu siêu nhẹ
✅ **Người ghét VirtualBox/VMware** vì nặng, khởi động chậm, ngốn RAM ngầm

---

## 📋 Yêu cầu hệ thống

| Mục | Tối thiểu | Khuyến nghị |
|-----|-----------|-------------|
| **Hệ điều hành** | Linux Mint 22.x / Ubuntu 24.04 | Linux Mint 22.x Cinnamon |
| **CPU** | 2 nhân, hỗ trợ VT-x/AMD-V | 4 nhân Intel/AMD đời mới |
| **RAM** | 4 GB | 8 GB+ |
| **Ổ cứng trống** | 10 GB (cho Win XP/2000) | 50 GB+ (cho Win 11) |
| **Kết nối Internet** | Có (để tải ISO ~3-8GB lần đầu) | Băng thông >10 Mbps |
| **Quyền** | sudo | sudo |

**Kiểm tra hỗ trợ ảo hóa:**
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
# Kết quả > 0 = OK
```

---

## 🚀 Cài đặt nhanh

### Cách 1: Clone repo

```bash
git clone https://github.com/webdep24h/win-docker-manager.git
cd win-docker-manager
chmod +x win-docker-manager.sh
./win-docker-manager.sh
```

### Cách 2: Tải trực tiếp file script

```bash
wget https://raw.githubusercontent.com/webdep24h/win-docker-manager/refs/heads/main/win-docker-manager.sh
chmod +x win-docker-manager.sh
./win-docker-manager.sh
```

### Cách 3: Chạy luôn (one-liner)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/webdep24h/win-docker-manager/refs/heads/main/win-docker-manager.sh)
```

> ⚠ **Lưu ý**: KHÔNG chạy bằng `sudo`. Script sẽ tự xin quyền sudo khi cần.

### Sau khi chạy, bạn sẽ thấy menu chính:

```
╔══════════════════════════════════════════════════════════════╗
║         WIN-DOCKER MANAGER  -  Linux Mint 22.x              ║
║      Windows trên Docker - Siêu nhẹ, ít RAM, ít ổ           ║
╚══════════════════════════════════════════════════════════════╝

Bạn muốn làm gì?

  1) 🚀 CÀI ĐẶT Windows trên Docker
  2) 🗑  GỠ CÀI ĐẶT (sạch hoàn toàn)
  3) 📊 Xem trạng thái hiện tại
  0) Thoát
```

---

## 📦 Danh sách phiên bản Windows hỗ trợ

Script hỗ trợ **18 phiên bản chính thức** từ kho `dockur/windows`:

### 🟢 Windows 11
| ID | Phiên bản | Kích thước ISO |
|----|-----------|----------------|
| `11` | Windows 11 Pro | 7.9 GB |
| `11l` | **Windows 11 LTSC ★ Nhẹ** | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |

### 🔵 Windows 10
| ID | Phiên bản | Kích thước ISO |
|----|-----------|----------------|
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | **Windows 10 LTSC ★ Nhẹ** | 4.6 GB |
| `10e` | Windows 10 Enterprise | 5.2 GB |

### 🟣 Windows cũ (siêu nhẹ)
| ID | Phiên bản | Kích thước ISO |
|----|-----------|----------------|
| `8e` | Windows 8.1 Enterprise | 3.7 GB |
| `7u` | Windows 7 Ultimate | 3.1 GB |
| `vu` | Windows Vista Ultimate | 3.0 GB |
| `xp` | **Windows XP Pro ★★ Siêu nhẹ** | 0.6 GB |
| `2k` | **Windows 2000 Pro ★★ Siêu nhẹ** | 0.4 GB |

### 🟠 Windows Server
| ID | Phiên bản | Kích thước ISO |
|----|-----------|----------------|
| `2025` | Windows Server 2025 | 7.6 GB |
| `2022` | Windows Server 2022 | 6.0 GB |
| `2019` | Windows Server 2019 | 5.3 GB |
| `2016` | Windows Server 2016 | 6.5 GB |
| `2012` | Windows Server 2012 | 4.3 GB |
| `2008` | Windows Server 2008 | 3.0 GB |
| `2003` | Windows Server 2003 | 0.6 GB |

### 🔧 ISO tùy biến (Tiny11, Tiny10, ReviOS...)
Chọn lựa chọn `99` và nhập URL ISO trực tiếp:

```
https://archive.org/download/tiny-11-NTDEV/tiny11%2023H2%20x64.iso
```

> 💡 **Khuyến nghị cho máy yếu**: Chọn `Windows 11 LTSC` (4.7GB) hoặc `Windows XP` (0.6GB).

---

## ⚙️ Cấu hình tài nguyên thông minh

Khi chọn **CÀI ĐẶT**, script sẽ tự dò máy bạn và gợi ý cấu hình:

```
💡 Máy bạn có 8GB RAM và 4 nhân CPU

RAM cấp cho Windows (mặc định 3G, vd: 2G/3G/4G): _
Số nhân CPU (mặc định 2): _
Dung lượng ổ cứng ảo (mặc định 40G): _
Username Windows (mặc định: user): _
Password Windows (mặc định: admin): _
Ngôn ngữ Windows (English/Vietnamese..., mặc định English): _
```

**Bảng quy tắc tự động:**

| RAM máy Linux | RAM cấp cho Windows |
|---------------|---------------------|
| ≤ 4 GB | 2G |
| 5-8 GB | 3G |
| 9-16 GB | 4G |
| > 16 GB | 6G |

Bạn có thể nhập Enter để dùng giá trị mặc định, hoặc tự nhập theo ý.

---

## 🎮 5 Alias siêu tiện

Sau khi cài, script **tự thêm và áp dụng ngay** 5 alias vào `~/.bashrc`:

### `win-init` - ▶ Khởi tạo lần đầu
```bash
win-init
```
Tương đương: `cd ~/windows-docker && docker compose up -d`
Tải image `dockurr/windows`, khởi tạo container, tải ISO Windows (10-15 phút lần đầu).

### `win-start` - ▶ Bật Windows
```bash
win-start
```
Khởi động container đã có. Mất 10-30 giây để Windows boot xong, sau đó truy cập `http://localhost:8006`.

### `win-stop` - ⏹ Tắt và giải phóng RAM
```bash
win-stop
```
Tắt hoàn toàn container, **giải phóng 100% RAM** cho Linux. Dữ liệu Windows được lưu trong `~/windows-docker/data` - lần sau bật lên là dùng tiếp.

### `win-status` - 📊 Xem trạng thái
```bash
win-status
```
Hiển thị container có chạy không + mức RAM/CPU đang dùng.

### `win-logs` - 📜 Xem log debug
```bash
win-logs
```
Xem log container realtime (`Ctrl+C` để thoát). Dùng khi gặp lỗi cài đặt.

> 💡 **Tip**: Nếu các alias không hoạt động ngay, chạy `source ~/.bashrc` hoặc mở terminal mới.

---

## 🗑️ Gỡ cài đặt - 3 mức độ

Chạy lại script và chọn **2) Gỡ cài đặt**:

### Mức 1 - 🟢 NHẸ
Chỉ xóa Windows ảo, **giữ Docker** để dùng cho việc khác:
- ✅ Container `windows-docker`
- ✅ Image `dockurr/windows`
- ✅ Volume và network liên quan
- ✅ Thư mục `~/windows-docker/`
- ✅ 5 alias trong `~/.bashrc` (có backup)

**Dung lượng giải phóng:** ~10-40 GB tùy phiên bản Windows.

### Mức 2 - 🟡 TRUNG BÌNH
Mức 1 + **dọn sạch toàn bộ Docker data**:
- ✅ Tất cả container Docker khác trên máy
- ✅ Tất cả image Docker khác
- ✅ Tất cả volume Docker khác
- ✅ `docker system prune -af --volumes`

⚠ **Cảnh báo**: Nếu bạn có project Docker khác → hãy chọn Mức 1.

### Mức 3 - 🔴 HOÀN TOÀN
Mức 2 + **gỡ luôn Docker Engine**:
- ✅ Gỡ packages: `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-compose-plugin`, `docker-buildx-plugin`
- ✅ Xóa `/var/lib/docker/` và `/var/lib/containerd/`
- ✅ Xóa repository Docker và GPG key
- ✅ Xóa group `docker`
- ✅ Xóa `docker-compose` standalone

**Kết quả**: Linux Mint trở lại như **chưa từng cài Docker**.

### 🔒 Cơ chế an toàn 2 lớp

```
1. Menu chọn mức (mặc định không làm gì)
2. Phải gõ chính xác 'YES' (chữ hoa) để xác nhận
```

Không thể xóa nhầm.

---

## 📊 So sánh với các giải pháp khác

| Tiêu chí | Win-Docker Manager | VirtualBox | VMware Player | Wine | Cài thủ công dockur/windows |
|----------|:------------------:|:----------:|:-------------:|:----:|:---------------------------:|
| **Dễ cài đặt** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Nhẹ RAM** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Không tự chạy ngầm** | ✅ | ❌ | ❌ | N/A | ⚠ Phải cấu hình thủ công |
| **Chạy app Windows native** | ✅ | ✅ | ✅ | ⚠ Một số app | ✅ |
| **Truy cập qua trình duyệt** | ✅ | ❌ | ❌ | N/A | ✅ |
| **Tự phát hiện KVM** | ✅ | N/A | N/A | N/A | ❌ |
| **Hỗ trợ ISO tùy biến** | ✅ | ✅ | ✅ | N/A | ✅ |
| **Gỡ sạch hoàn toàn** | ✅ (3 mức) | ⚠ Khó | ⚠ Khó | ⭐⭐⭐ | ❌ |
| **Lệnh quản lý ngắn gọn** | ✅ (5 alias) | ❌ | ❌ | N/A | ❌ |
| **UI thân thiện** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐ |
| **Miễn phí** | ✅ | ✅ | ⚠ Personal use | ✅ | ✅ |

---

## 💡 Use case thực tế

### 🇻🇳 Case 1: Chạy UltraViewer cho khách hàng VN
```bash
./win-docker-manager.sh   # Chọn 1 → 11l (Win 11 LTSC) → cấu hình mặc định
win-init                  # Đợi 10-15 phút
# Vào http://localhost:8006 → tải UltraViewer trong Windows → cài → dùng
win-stop                  # Tắt khi không dùng → giải phóng RAM
```

### 💼 Case 2: Test app trên Windows Server 2022
```bash
./win-docker-manager.sh   # Chọn 1 → 13 (Server 2022) → RAM 6G, CPU 4
win-init
# Deploy app .NET vào Windows Server qua RDP (port 3389)
```

### 🎮 Case 3: Chơi game cũ trên Windows XP
```bash
./win-docker-manager.sh   # Chọn 1 → 10 (XP) → RAM 1G, Disk 16G
# Chỉ tốn 600MB tải về, ổ ảo 16GB - máy yếu vẫn chạy mượt
```

### 🏢 Case 4: Truy cập app ngân hàng Việt Nam
```bash
# Một số app ngân hàng VN chỉ chạy trên Windows → giải pháp:
./win-docker-manager.sh   # Cài Win 10 LTSC (nhẹ, ổn định, hỗ trợ chữ ký số)
```

---

## 🔧 Khắc phục sự cố

### ❌ Lỗi: "permission denied" khi chạy docker
```bash
# Đăng xuất và đăng nhập lại, hoặc:
newgrp docker
```

### ❌ Lỗi: "/dev/kvm not found"
- Kiểm tra BIOS đã bật **Intel VT-x** hoặc **AMD-V** chưa
- Test: `egrep -c '(vmx|svm)' /proc/cpuinfo` (phải > 0)
- Cài kvm: `sudo apt install qemu-kvm libvirt-daemon-system`

### ❌ Windows boot rất chậm
- Phải có KVM (xem trên)
- Tăng RAM trong `~/windows-docker/docker-compose.yml`: `RAM_SIZE: "4G"`
- Restart: `win-stop && win-start`

### ❌ Không truy cập được http://localhost:8006
```bash
win-status              # Kiểm tra container có chạy
win-logs                # Xem log lỗi
# Đợi 30-60s sau khi win-start vì Windows cần boot
```

### ❌ Hết dung lượng ổ cứng
```bash
# Chạy script → chọn 2 (Gỡ) → chọn mức 1
# Hoặc dọn Docker:
docker system prune -af --volumes
```

### ❌ Mất alias `win-*` sau khi đóng terminal
```bash
source ~/.bashrc        # Tải lại alias
# Hoặc mở terminal mới
```

---

## 📝 Đóng góp

Đóng góp luôn được chào đón! Cách tham gia:

1. Fork repository này
2. Tạo branch mới: `git checkout -b feature/AmazingFeature`
3. Commit thay đổi: `git commit -m 'Add some AmazingFeature'`
4. Push branch: `git push origin feature/AmazingFeature`
5. Mở Pull Request

### Báo lỗi (Issues)
Khi báo lỗi, vui lòng cung cấp:
- Phiên bản Linux Mint: `lsb_release -a`
- Phiên bản Docker: `docker --version`
- Output của `win-logs`
- Phiên bản Windows đã chọn

### Ý tưởng mở rộng tương lai
- [ ] Hỗ trợ Linux Mint 21.x (Ubuntu 22.04)
- [ ] Hỗ trợ Fedora / Arch Linux
- [ ] GUI bằng Zenity/YAD
- [ ] Snapshot/restore container
- [ ] Tự cài UltraViewer/TeamViewer sau khi Windows xong (qua `install.bat`)
- [ ] Hỗ trợ chia sẻ thư mục host ↔ Windows

---

## 📄 License

Phân phối theo giấy phép MIT. Xem file `LICENSE` để biết chi tiết.

```
MIT License - Tự do sử dụng, chỉnh sửa, phân phối cho mục đích cá nhân và thương mại.
```

---

## 🙏 Lời cảm ơn

Dự án này được xây dựng dựa trên:

- 🌟 [**dockur/windows**](https://github.com/dockur/windows) - Image Docker tuyệt vời cho phép chạy Windows trong container
- 🐳 [**Docker**](https://www.docker.com/) - Nền tảng container hoá
- 🐧 [**Linux Mint**](https://linuxmint.com/) - Distro Linux thân thiện nhất cho người dùng cuối
- 💚 Cộng đồng Linux Việt Nam

Nếu script hữu ích, hãy ⭐ **star repo** và chia sẻ cho bạn bè nhé!

---

## 📞 Liên hệ

- 🐛 **Báo lỗi**: [GitHub Issues](https://github.com/webdep24h/win-docker-manager/issues)
- 💬 **Thảo luận**: [GitHub Discussions](https://github.com/webdep24h/win-docker-manager/discussions)

---

<div align="center">

**⭐ Nếu thấy hữu ích, đừng quên star repo nhé! ⭐**

Made with ❤️ for Linux Mint Vietnam Community

</div>

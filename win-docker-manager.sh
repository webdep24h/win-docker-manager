#!/bin/bash
###############################################################################
#  WIN-DOCKER MANAGER - All-in-One Script
#  Cài & Gỡ Windows trên Docker - Tối ưu Linux Mint 22.x
#  Siêu nhẹ - Ít RAM - Ít ổ cứng
#
#  Repository: https://github.com/YOUR_USERNAME/win-docker-manager
#  License: MIT
###############################################################################

set -u  # Báo lỗi khi dùng biến chưa khai báo

# ============= MÀU SẮC =============
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR ]${NC} $1"; }
step()  { echo -e "\n${BOLD}${CYAN}▶ $1${NC}"; }

# ============= CẤU HÌNH MẶC ĐỊNH =============
WORK_DIR="$HOME/windows-docker"
CONTAINER_NAME="windows-docker"
IMAGE_NAME="dockurr/windows"

# ============= KIỂM TRA QUYỀN =============
if [ "$EUID" -eq 0 ]; then
    err "KHÔNG chạy bằng sudo! Hãy chạy với user thường."
    exit 1
fi

###############################################################################
# HÀM: LẤY SUDO + GIỮ SESSION
###############################################################################
acquire_sudo() {
    info "Cần quyền sudo cho một số thao tác. Nhập mật khẩu nếu được hỏi..."
    sudo -v
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null ) &
    SUDO_PID=$!
    trap 'kill $SUDO_PID 2>/dev/null' EXIT
}

###############################################################################
# HÀM: HIỂN THỊ BANNER
###############################################################################
show_banner() {
    clear
    echo -e "${GREEN}${BOLD}"
    cat <<'BANNER'
╔══════════════════════════════════════════════════════════════╗
║         WIN-DOCKER MANAGER  -  Linux Mint 22.x              ║
║      Windows trên Docker - Siêu nhẹ, ít RAM, ít ổ           ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

###############################################################################
# HÀM: MENU CHỌN PHIÊN BẢN WINDOWS
###############################################################################
select_windows_version() {
    echo -e "${BOLD}📦 CHỌN PHIÊN BẢN WINDOWS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}🟢 Windows 11:${NC}"
    echo -e "   ${GREEN}1)${NC} 11    - Windows 11 Pro              (7.9 GB)"
    echo -e "   ${GREEN}2)${NC} 11l   - Windows 11 LTSC ${YELLOW}★ Nhẹ${NC}     (4.7 GB)"
    echo -e "   ${GREEN}3)${NC} 11e   - Windows 11 Enterprise       (6.6 GB)"
    echo ""
    echo -e "${BOLD}🔵 Windows 10:${NC}"
    echo -e "   ${GREEN}4)${NC} 10    - Windows 10 Pro              (5.7 GB)"
    echo -e "   ${GREEN}5)${NC} 10l   - Windows 10 LTSC ${YELLOW}★ Nhẹ${NC}     (4.6 GB)"
    echo -e "   ${GREEN}6)${NC} 10e   - Windows 10 Enterprise       (5.2 GB)"
    echo ""
    echo -e "${BOLD}🟣 Windows cũ (siêu nhẹ):${NC}"
    echo -e "   ${GREEN}7)${NC} 8e    - Windows 8.1 Enterprise      (3.7 GB)"
    echo -e "   ${GREEN}8)${NC} 7u    - Windows 7 Ultimate          (3.1 GB)"
    echo -e "   ${GREEN}9)${NC} vu    - Windows Vista Ultimate      (3.0 GB)"
    echo -e "   ${GREEN}10)${NC} xp   - Windows XP Pro ${YELLOW}★★ Siêu nhẹ${NC} (0.6 GB)"
    echo -e "   ${GREEN}11)${NC} 2k   - Windows 2000 Pro ${YELLOW}★★ Siêu nhẹ${NC} (0.4 GB)"
    echo ""
    echo -e "${BOLD}🟠 Windows Server:${NC}"
    echo -e "   ${GREEN}12)${NC} 2025 - Windows Server 2025         (7.6 GB)"
    echo -e "   ${GREEN}13)${NC} 2022 - Windows Server 2022         (6.0 GB)"
    echo -e "   ${GREEN}14)${NC} 2019 - Windows Server 2019         (5.3 GB)"
    echo -e "   ${GREEN}15)${NC} 2016 - Windows Server 2016         (6.5 GB)"
    echo -e "   ${GREEN}16)${NC} 2012 - Windows Server 2012         (4.3 GB)"
    echo -e "   ${GREEN}17)${NC} 2008 - Windows Server 2008         (3.0 GB)"
    echo -e "   ${GREEN}18)${NC} 2003 - Windows Server 2003         (0.6 GB)"
    echo ""
    echo -e "${BOLD}🔧 Tùy chỉnh:${NC}"
    echo -e "   ${GREEN}99)${NC} Nhập URL ISO tùy biến (ví dụ tiny11/tiny10)"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -rp "Lựa chọn của bạn (mặc định 2 - Win11 LTSC): " VER_CHOICE
    VER_CHOICE=${VER_CHOICE:-2}

    case "$VER_CHOICE" in
        1)  WIN_VERSION="11";   WIN_NAME="Windows 11 Pro";        SUGGEST_DISK="64G" ;;
        2)  WIN_VERSION="11l";  WIN_NAME="Windows 11 LTSC";       SUGGEST_DISK="40G" ;;
        3)  WIN_VERSION="11e";  WIN_NAME="Windows 11 Enterprise"; SUGGEST_DISK="64G" ;;
        4)  WIN_VERSION="10";   WIN_NAME="Windows 10 Pro";        SUGGEST_DISK="48G" ;;
        5)  WIN_VERSION="10l";  WIN_NAME="Windows 10 LTSC";       SUGGEST_DISK="40G" ;;
        6)  WIN_VERSION="10e";  WIN_NAME="Windows 10 Enterprise"; SUGGEST_DISK="48G" ;;
        7)  WIN_VERSION="8e";   WIN_NAME="Windows 8.1 Enterprise";SUGGEST_DISK="32G" ;;
        8)  WIN_VERSION="7u";   WIN_NAME="Windows 7 Ultimate";    SUGGEST_DISK="32G" ;;
        9)  WIN_VERSION="vu";   WIN_NAME="Windows Vista Ultimate";SUGGEST_DISK="32G" ;;
        10) WIN_VERSION="xp";   WIN_NAME="Windows XP Pro";        SUGGEST_DISK="16G" ;;
        11) WIN_VERSION="2k";   WIN_NAME="Windows 2000 Pro";      SUGGEST_DISK="16G" ;;
        12) WIN_VERSION="2025"; WIN_NAME="Windows Server 2025";   SUGGEST_DISK="64G" ;;
        13) WIN_VERSION="2022"; WIN_NAME="Windows Server 2022";   SUGGEST_DISK="64G" ;;
        14) WIN_VERSION="2019"; WIN_NAME="Windows Server 2019";   SUGGEST_DISK="48G" ;;
        15) WIN_VERSION="2016"; WIN_NAME="Windows Server 2016";   SUGGEST_DISK="48G" ;;
        16) WIN_VERSION="2012"; WIN_NAME="Windows Server 2012";   SUGGEST_DISK="32G" ;;
        17) WIN_VERSION="2008"; WIN_NAME="Windows Server 2008";   SUGGEST_DISK="32G" ;;
        18) WIN_VERSION="2003"; WIN_NAME="Windows Server 2003";   SUGGEST_DISK="16G" ;;
        99)
            read -rp "Nhập URL trực tiếp tới file ISO: " CUSTOM_URL
            if [ -z "$CUSTOM_URL" ]; then
                err "URL trống. Hủy."
                exit 1
            fi
            WIN_VERSION="$CUSTOM_URL"
            WIN_NAME="ISO tùy biến"
            SUGGEST_DISK="32G"
            ;;
        *)
            err "Lựa chọn không hợp lệ."
            exit 1
            ;;
    esac

    ok "Đã chọn: ${BOLD}$WIN_NAME${NC} (VERSION=$WIN_VERSION)"
}

###############################################################################
# HÀM: HỎI CẤU HÌNH RAM/CPU/DISK
###############################################################################
ask_resources() {
    echo ""
    echo -e "${BOLD}⚙ CẤU HÌNH TÀI NGUYÊN${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Phát hiện RAM máy
    TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM_GB" -le 4 ]; then
        DEFAULT_RAM="2G"
    elif [ "$TOTAL_RAM_GB" -le 8 ]; then
        DEFAULT_RAM="3G"
    elif [ "$TOTAL_RAM_GB" -le 16 ]; then
        DEFAULT_RAM="4G"
    else
        DEFAULT_RAM="6G"
    fi

    CPU_CORES_TOTAL=$(nproc)
    if [ "$CPU_CORES_TOTAL" -le 2 ]; then
        DEFAULT_CPU="2"
    elif [ "$CPU_CORES_TOTAL" -le 4 ]; then
        DEFAULT_CPU="2"
    else
        DEFAULT_CPU="4"
    fi

    echo -e "💡 Máy bạn có ${BOLD}${TOTAL_RAM_GB}GB RAM${NC} và ${BOLD}${CPU_CORES_TOTAL} nhân CPU${NC}"
    echo ""
    read -rp "RAM cấp cho Windows (mặc định $DEFAULT_RAM, vd: 2G/3G/4G): " RAM_SIZE
    RAM_SIZE=${RAM_SIZE:-$DEFAULT_RAM}

    read -rp "Số nhân CPU (mặc định $DEFAULT_CPU): " CPU_CORES
    CPU_CORES=${CPU_CORES:-$DEFAULT_CPU}

    read -rp "Dung lượng ổ cứng ảo (mặc định $SUGGEST_DISK): " DISK_SIZE
    DISK_SIZE=${DISK_SIZE:-$SUGGEST_DISK}

    read -rp "Username Windows (mặc định: user): " WIN_USER
    WIN_USER=${WIN_USER:-user}

    read -rsp "Password Windows (mặc định: admin): " WIN_PASS
    WIN_PASS=${WIN_PASS:-admin}
    echo ""

    read -rp "Ngôn ngữ Windows (English/Vietnamese..., mặc định English): " WIN_LANG
    WIN_LANG=${WIN_LANG:-English}

    ok "Cấu hình: RAM=$RAM_SIZE | CPU=$CPU_CORES | Disk=$DISK_SIZE | User=$WIN_USER | Lang=$WIN_LANG"
}

###############################################################################
# HÀM: CÀI ĐẶT (INSTALL)
###############################################################################
do_install() {
    show_banner
    echo -e "${BOLD}🚀 CHẾ ĐỘ CÀI ĐẶT${NC}\n"

    select_windows_version
    ask_resources
    acquire_sudo

    ###########################################################################
    # BƯỚC 1: CẬP NHẬT HỆ THỐNG
    ###########################################################################
    step "[1/5] Cập nhật hệ thống & cài gói cần thiết..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        curl wget ca-certificates gnupg lsb-release \
        apt-transport-https software-properties-common uidmap
    ok "Đã cài xong gói cơ bản."

    ###########################################################################
    # BƯỚC 2: CÀI DOCKER ENGINE
    ###########################################################################
    step "[2/5] Cài đặt Docker Engine..."
    if ! command -v docker &>/dev/null; then
        sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Linux Mint 22.x dựa trên Ubuntu 24.04 (noble)
        UBUNTU_CODENAME="noble"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

        sudo apt-get update -qq
        sudo apt-get install -y -qq \
            docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
        ok "Docker Engine đã cài xong."
    else
        ok "Docker đã có sẵn: $(docker --version)"
    fi

    sudo systemctl enable docker >/dev/null 2>&1
    sudo systemctl start docker

    ###########################################################################
    # BƯỚC 3: DOCKER COMPOSE + QUYỀN
    ###########################################################################
    step "[3/5] Kiểm tra Docker Compose & quyền user..."
    if docker compose version &>/dev/null; then
        ok "Docker Compose plugin: $(docker compose version --short)"
    else
        warn "Cài docker-compose standalone..."
        sudo curl -fsSL \
            "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
            -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        ok "Đã cài docker-compose standalone."
    fi

    NEED_RELOGIN=0
    if ! groups "$USER" | grep -q '\bdocker\b'; then
        sudo groupadd docker 2>/dev/null || true
        sudo usermod -aG docker "$USER"
        NEED_RELOGIN=1
        warn "Đã thêm user '$USER' vào group docker. Cần đăng xuất/đăng nhập lại!"
    else
        ok "User đã thuộc group docker."
    fi

    ###########################################################################
    # BƯỚC 4: KIỂM TRA KVM
    ###########################################################################
    step "[4/5] Kiểm tra hỗ trợ KVM..."
    KVM_AVAILABLE=0
    if [ -e /dev/kvm ]; then
        KVM_AVAILABLE=1
        ok "KVM khả dụng - Windows sẽ chạy nhanh!"
        if [ ! -r /dev/kvm ] || [ ! -w /dev/kvm ]; then
            warn "User chưa có quyền /dev/kvm. Đang thêm vào group kvm..."
            sudo usermod -aG kvm "$USER" 2>/dev/null || true
            NEED_RELOGIN=1
        fi
    else
        warn "KVM KHÔNG khả dụng. Bật Virtualization (VT-x/AMD-V) trong BIOS."
        warn "Container vẫn chạy được nhưng chậm hơn."
    fi

    ###########################################################################
    # BƯỚC 5: TẠO THƯ MỤC + DOCKER-COMPOSE.YML
    ###########################################################################
    step "[5/5] Tạo thư mục $WORK_DIR và docker-compose.yml..."

    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR" || exit 1

    # Backup file cũ nếu có
    if [ -f docker-compose.yml ]; then
        cp docker-compose.yml "docker-compose.yml.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Đã backup file docker-compose.yml cũ."
    fi

    # Sinh file docker-compose.yml
    {
        cat <<YAML
services:
  windows:
    image: dockurr/windows
    container_name: ${CONTAINER_NAME}
    environment:
      VERSION: "${WIN_VERSION}"
      RAM_SIZE: "${RAM_SIZE}"
      CPU_CORES: "${CPU_CORES}"
      DISK_SIZE: "${DISK_SIZE}"
      USERNAME: "${WIN_USER}"
      PASSWORD: "${WIN_PASS}"
      LANGUAGE: "${WIN_LANG}"
      REGION: "vi-VN"
      KEYBOARD: "vi-VN"
YAML
        if [ "$KVM_AVAILABLE" -eq 1 ]; then
            cat <<'YAML'
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
YAML
        fi
        cat <<'YAML'
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    volumes:
      - ./data:/storage
    restart: "no"
    stop_grace_period: 2m
YAML
    } > docker-compose.yml

    ok "Đã tạo $WORK_DIR/docker-compose.yml"

    ###########################################################################
    # TẠO CÁC SCRIPT TIỆN ÍCH
    ###########################################################################
    info "Tạo các script tiện ích..."

    cat > start-windows.sh <<'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "▶ Khởi động Windows..."
docker compose start 2>/dev/null || docker-compose start
echo ""
echo "✅ Đang chạy. Truy cập: http://localhost:8006"
EOF

    cat > stop-windows.sh <<'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "⏹ Đang tắt Windows..."
docker compose stop 2>/dev/null || docker-compose stop
echo "✅ Đã tắt. RAM giải phóng 100%."
EOF

    cat > status-windows.sh <<'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "📊 Trạng thái container:"
docker compose ps 2>/dev/null || docker-compose ps
echo ""
echo "💾 RAM/CPU đang dùng:"
docker stats --no-stream windows-docker 2>/dev/null || echo "(Container chưa chạy)"
EOF

    chmod +x ./*.sh
    ok "Đã tạo: start-windows.sh / stop-windows.sh / status-windows.sh"

    ###########################################################################
    # TẠO ALIAS
    ###########################################################################
    SHELL_RC="$HOME/.bashrc"
    # Xóa block alias cũ nếu có (để cập nhật mới)
    if grep -q "# >>> win-docker aliases" "$SHELL_RC" 2>/dev/null; then
        sed -i '/# >>> win-docker aliases >>>/,/# <<< win-docker aliases <<</d' "$SHELL_RC"
    fi

    cat >> "$SHELL_RC" <<EOF

# >>> win-docker aliases >>>
alias win-init='cd $WORK_DIR && (docker compose up -d || docker-compose up -d) && echo "→ Mở http://localhost:8006 sau 10-30s"'
alias win-start='cd $WORK_DIR && (docker compose start || docker-compose start) && echo "→ http://localhost:8006"'
alias win-stop='cd $WORK_DIR && (docker compose stop || docker-compose stop) && echo "✅ Đã tắt, giải phóng RAM."'
alias win-status='cd $WORK_DIR && (docker compose ps || docker-compose ps) && docker stats --no-stream $CONTAINER_NAME 2>/dev/null'
alias win-logs='cd $WORK_DIR && (docker compose logs -f || docker-compose logs -f)'
# <<< win-docker aliases <<<
EOF
    ok "Đã thêm 5 alias: win-init / win-start / win-stop / win-status / win-logs"

    # Tự áp dụng alias cho session hiện tại
    # shellcheck disable=SC1090
    source "$SHELL_RC" 2>/dev/null || true

    ###########################################################################
    # KHỞI CHẠY TỰ ĐỘNG (TÙY CHỌN)
    ###########################################################################
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    AUTO_START="n"
    if [ "$NEED_RELOGIN" -eq 0 ]; then
        read -rp "Khởi chạy Windows ngay bây giờ? (y/n, mặc định y): " AUTO_START
        AUTO_START=${AUTO_START:-y}
    else
        warn "Cần đăng xuất/đăng nhập lại trước khi chạy Windows."
    fi

    if [[ "$AUTO_START" =~ ^[Yy]$ ]]; then
        info "Đang tải image và khởi chạy Windows... (mất 10-15 phút lần đầu)"
        cd "$WORK_DIR" || exit 1
        docker compose up -d 2>/dev/null || docker-compose up -d
        sleep 5
        ok "Container đã chạy. Truy cập: ${GREEN}http://localhost:8006${NC}"
    fi

    show_install_summary
}

###############################################################################
# HÀM: HIỂN THỊ TỔNG KẾT SAU KHI CÀI
###############################################################################
show_install_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                  ✅  CÀI ĐẶT HOÀN TẤT  ✅                    ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "${NEED_RELOGIN:-0}" -eq 1 ]; then
        echo -e "${YELLOW}${BOLD}⚠ QUAN TRỌNG:${NC} Hãy ${BOLD}đăng xuất → đăng nhập lại${NC} (hoặc reboot)"
        echo -e "  để quyền docker có hiệu lực. Tạm thời có thể dùng: ${YELLOW}newgrp docker${NC}"
        echo ""
    fi

    echo -e "${BOLD}📋 HƯỚNG DẪN SỬ DỤNG${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}1️⃣  LẦN ĐẦU${NC} (tải $WIN_NAME, mất 10-15 phút):"
    echo -e "    ${YELLOW}win-init${NC}"
    echo ""
    echo -e "${BOLD}2️⃣  TRUY CẬP TRÌNH DUYỆT:${NC}"
    echo -e "    👉  ${GREEN}${BOLD}http://localhost:8006${NC}"
    echo -e "    Windows sẽ tự cài đặt từ A-Z."
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🎮 5 ALIAS BẬT/TẮT HÀNG NGÀY${NC} (đã tự áp dụng)"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}win-init${NC}     ▶ Lần đầu - khởi tạo + tải Windows"
    echo -e "  ${YELLOW}win-start${NC}    ▶ Bật Windows khi cần dùng"
    echo -e "  ${YELLOW}win-stop${NC}     ⏹ Tắt hoàn toàn, giải phóng 100% RAM"
    echo -e "  ${YELLOW}win-status${NC}   📊 Xem RAM/CPU đang dùng"
    echo -e "  ${YELLOW}win-logs${NC}     📜 Xem log nếu lỗi"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}🔐 ĐĂNG NHẬP WINDOWS:${NC}"
    echo -e "     Username: ${GREEN}$WIN_USER${NC}"
    echo -e "     Password: ${GREEN}$WIN_PASS${NC}"
    echo ""
    echo -e "${BOLD}📦 PHIÊN BẢN:${NC}  ${GREEN}$WIN_NAME${NC} (VERSION=$WIN_VERSION)"
    echo -e "${BOLD}⚙ CẤU HÌNH:${NC}   RAM=$RAM_SIZE | CPU=$CPU_CORES | Disk=$DISK_SIZE"
    echo -e "${BOLD}📁 THƯ MỤC:${NC}   $WORK_DIR"
    echo ""
    echo -e "${YELLOW}⚠ LƯU Ý:${NC} restart=\"no\" → Windows KHÔNG tự chạy ngầm khi bật máy."
    echo ""
    echo -e "${BLUE}💡 Tip:${NC} Chạy ${YELLOW}source ~/.bashrc${NC} nếu các alias chưa hoạt động."
    echo ""
}

###############################################################################
# HÀM: GỠ CÀI ĐẶT (UNINSTALL)
###############################################################################
do_uninstall() {
    show_banner
    echo -e "${RED}${BOLD}🗑  CHẾ ĐỘ GỠ CÀI ĐẶT${NC}\n"

    echo -e "${BOLD}Chọn mức độ gỡ:${NC}"
    echo -e "  ${GREEN}1)${NC} ${BOLD}NHẸ${NC}      - Chỉ xóa Windows ảo (giữ Docker)"
    echo -e "  ${YELLOW}2)${NC} ${BOLD}TRUNG BÌNH${NC} - Mức 1 + dọn sạch toàn bộ Docker data"
    echo -e "  ${RED}3)${NC} ${BOLD}HOÀN TOÀN${NC} - Mức 2 + gỡ luôn Docker Engine"
    echo -e "  ${BLUE}0)${NC} Hủy"
    echo ""
    read -rp "Lựa chọn (0/1/2/3): " LEVEL

    case "$LEVEL" in
        0) info "Đã hủy."; exit 0 ;;
        1|2|3) ;;
        *) err "Lựa chọn không hợp lệ."; exit 1 ;;
    esac

    echo ""
    echo -e "${RED}${BOLD}⚠ CẢNH BÁO ⚠${NC}"
    case "$LEVEL" in
        1) echo -e "Sắp xóa: ${BOLD}Windows ảo + $WORK_DIR${NC}" ;;
        2) echo -e "Sắp xóa: Windows ảo + ${BOLD}TOÀN BỘ Docker data${NC}" ;;
        3) echo -e "Sắp xóa: ${BOLD}MỌI THỨ + Docker Engine${NC}" ;;
    esac
    echo ""
    read -rp "Gõ 'YES' để xác nhận: " CONFIRM
    if [ "$CONFIRM" != "YES" ]; then
        info "Đã hủy."
        exit 0
    fi

    acquire_sudo
    START_TIME=$(date +%s)

    ###########################################################################
    # BƯỚC 1: DỪNG VÀ XÓA CONTAINER
    ###########################################################################
    step "[1] Dừng & xóa container Windows..."
    if [ -d "$WORK_DIR" ] && [ -f "$WORK_DIR/docker-compose.yml" ]; then
        cd "$WORK_DIR" || true
        docker compose down -v --remove-orphans 2>/dev/null \
            || docker-compose down -v --remove-orphans 2>/dev/null \
            || warn "Compose down không thực hiện được (có thể đã tắt)."
        cd "$HOME" || true
    fi

    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
        ok "Đã xóa container '$CONTAINER_NAME'."
    else
        info "Không có container '$CONTAINER_NAME'."
    fi

    ###########################################################################
    # BƯỚC 2: XÓA IMAGE
    ###########################################################################
    step "[2] Xóa image $IMAGE_NAME..."
    if docker images --format '{{.Repository}}' 2>/dev/null | grep -q "^${IMAGE_NAME}$"; then
        IMG_SIZE=$(docker images "$IMAGE_NAME" --format '{{.Size}}' | head -1)
        info "Image kích thước: $IMG_SIZE"
        docker rmi -f "$IMAGE_NAME" 2>/dev/null && ok "Đã xóa image." \
            || warn "Không xóa được image."
    else
        info "Không có image $IMAGE_NAME."
    fi

    ###########################################################################
    # BƯỚC 3: XÓA VOLUME + NETWORK
    ###########################################################################
    step "[3] Xóa volume & network liên quan..."
    WIN_VOLUMES=$(docker volume ls -q 2>/dev/null | grep -i "windows-docker" || true)
    if [ -n "$WIN_VOLUMES" ]; then
        echo "$WIN_VOLUMES" | xargs -r docker volume rm -f 2>/dev/null
        ok "Đã xóa volume."
    fi

    WIN_NETWORKS=$(docker network ls --format '{{.Name}}' 2>/dev/null | grep -i "windows-docker" || true)
    if [ -n "$WIN_NETWORKS" ]; then
        echo "$WIN_NETWORKS" | xargs -r -I {} docker network rm {} 2>/dev/null
        ok "Đã xóa network."
    fi

    ###########################################################################
    # BƯỚC 4: XÓA THƯ MỤC
    ###########################################################################
    step "[4] Xóa $WORK_DIR..."
    if [ -d "$WORK_DIR" ]; then
        DIR_SIZE=$(du -sh "$WORK_DIR" 2>/dev/null | cut -f1)
        info "Dung lượng: $DIR_SIZE"
        sudo rm -rf "$WORK_DIR" && ok "Đã giải phóng $DIR_SIZE" \
            || err "Không xóa được."
    else
        info "Thư mục không tồn tại."
    fi

    ###########################################################################
    # BƯỚC 5: XÓA ALIAS
    ###########################################################################
    step "[5] Xóa alias trong ~/.bashrc..."
    if grep -q "# >>> win-docker aliases" "$HOME/.bashrc" 2>/dev/null; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%Y%m%d_%H%M%S)"
        sed -i '/# >>> win-docker aliases >>>/,/# <<< win-docker aliases <<</d' "$HOME/.bashrc"
        ok "Đã xóa alias (backup tại ~/.bashrc.bak.*)."
    else
        info "Không có alias nào."
    fi

    ###########################################################################
    # MỨC 2: DỌN DOCKER DATA
    ###########################################################################
    if [ "$LEVEL" -ge 2 ]; then
        step "[6] Dọn sạch toàn bộ Docker (containers/images/volumes)..."
        warn "Sẽ xóa MỌI dữ liệu Docker khác trên máy!"

        RUNNING=$(docker ps -aq 2>/dev/null)
        [ -n "$RUNNING" ] && echo "$RUNNING" | xargs -r docker stop 2>/dev/null
        [ -n "$RUNNING" ] && echo "$RUNNING" | xargs -r docker rm -f 2>/dev/null

        ALL_IMG=$(docker images -q 2>/dev/null)
        [ -n "$ALL_IMG" ] && echo "$ALL_IMG" | xargs -r docker rmi -f 2>/dev/null

        ALL_VOL=$(docker volume ls -q 2>/dev/null)
        [ -n "$ALL_VOL" ] && echo "$ALL_VOL" | xargs -r docker volume rm -f 2>/dev/null

        docker system prune -af --volumes 2>/dev/null || true
        ok "Đã dọn sạch Docker."
    fi

    ###########################################################################
    # MỨC 3: GỠ DOCKER ENGINE
    ###########################################################################
    if [ "$LEVEL" -eq 3 ]; then
        step "[7] Gỡ Docker Engine hoàn toàn..."

        sudo systemctl stop docker docker.socket containerd 2>/dev/null || true
        sudo systemctl disable docker docker.socket containerd 2>/dev/null || true

        sudo apt-get purge -y \
            docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin \
            docker docker-engine docker.io containerd runc 2>/dev/null || true
        sudo apt-get autoremove -y 2>/dev/null || true

        sudo rm -f /usr/local/bin/docker-compose
        sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker
        sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg

        sudo groupdel docker 2>/dev/null || true
        sudo apt-get update -qq 2>/dev/null || true

        ok "Đã gỡ Docker Engine hoàn toàn."
    fi

    ###########################################################################
    # TỔNG KẾT GỠ
    ###########################################################################
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))

    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                  ✅  GỠ CÀI ĐẶT HOÀN TẤT  ✅                 ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  • Thời gian: ${ELAPSED}s"
    echo -e "  • Mức độ:    Mức $LEVEL"
    echo ""
    echo -e "${BOLD}💾 DUNG LƯỢNG Ổ ĐĨA:${NC}"
    df -h "$HOME" 2>/dev/null | tail -1 | awk '{printf "   $HOME: dùng %s / %s (%s)\n", $3, $2, $5}'
    echo ""

    if [ "$LEVEL" -eq 3 ]; then
        echo -e "${YELLOW}💡 Khuyến nghị reboot:${NC} ${YELLOW}sudo reboot${NC}"
    else
        echo -e "${BLUE}💡 Mở terminal mới (hoặc source ~/.bashrc) để bỏ alias.${NC}"
    fi
    echo ""
}

###############################################################################
# MENU CHÍNH
###############################################################################
main_menu() {
    show_banner
    echo -e "${BOLD}Bạn muốn làm gì?${NC}\n"
    echo -e "  ${GREEN}1)${NC} 🚀 ${BOLD}CÀI ĐẶT${NC} Windows trên Docker"
    echo -e "  ${RED}2)${NC} 🗑  ${BOLD}GỠ CÀI ĐẶT${NC} (sạch hoàn toàn)"
    echo -e "  ${BLUE}3)${NC} 📊 Xem trạng thái hiện tại"
    echo -e "  ${BLUE}0)${NC} Thoát"
    echo ""
    read -rp "Lựa chọn (0/1/2/3): " ACTION

    case "$ACTION" in
        1) do_install ;;
        2) do_uninstall ;;
        3)
            echo ""
            if [ -d "$WORK_DIR" ]; then
                ok "Thư mục cài đặt: $WORK_DIR"
                [ -f "$WORK_DIR/docker-compose.yml" ] && \
                    info "VERSION: $(grep 'VERSION:' "$WORK_DIR/docker-compose.yml" | head -1 | awk -F'"' '{print $2}')"
                if command -v docker &>/dev/null; then
                    echo ""
                    docker ps -a --filter "name=$CONTAINER_NAME" 2>/dev/null
                fi
            else
                warn "Chưa cài đặt. Chạy lại và chọn 1."
            fi
            echo ""
            ;;
        0) exit 0 ;;
        *) err "Lựa chọn không hợp lệ." ;;
    esac
}

# ============= ĐIỂM VÀO =============
main_menu

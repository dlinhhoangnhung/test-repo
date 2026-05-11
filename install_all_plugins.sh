#!/bin/sh
# install_all_plugins.sh

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "========================================"
echo "Installing All Plugins in Correct Order"
echo "========================================"

# Functional plugins list
PLUGINS="website partners contacts products inventories accounts accounting payments invoices purchases sales manufacturing employees time-off projects recruitments timesheets"

# Function to install a plugin
install_plugin() {
    local plugin_name=$1
    echo "Installing $plugin_name..."
    php artisan "$plugin_name:install" --no-interaction || echo "Lỗi khi cài đặt $plugin_name, có thể đã được cài hoặc không có lệnh install."
    echo "✓ $plugin_name processed"
    echo "-----------------------------------"
}

for plugin in $PLUGINS; do
    install_plugin "$plugin"
    sleep 1 # Tránh quá tải RAM/CPU
done

php artisan optimize
echo "Tất cả đã hoàn tất! Chúc mừng bạn đã thiết lập xong hệ thống."
#!/bin/sh
set -e

# 1. Đợi MySQL sẵn sàng
echo "Đang đợi MySQL..."
until nc -z -v -w30 $DB_HOST 3306; do
  echo "MySQL chưa sẵn sàng - đang đợi..."
  sleep 2
done

# 2. Đồng bộ folder public ra volume chung cho Nginx
mkdir -p /var/www/html/public_html
tar -cf - -C /var/www/html/public . | tar -xf - -C /var/www/html/public_html || true
chmod -R 755 /var/www/html/public_html

# 3. Đảm bảo quyền hạn cho storage và bootstrap/cache
echo "Đang thiết lập quyền hạn thư mục..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 7. Khởi động dịch vụ
if [ $# -gt 0 ]; then
    exec "$@"
else
    exec php-fpm
fi
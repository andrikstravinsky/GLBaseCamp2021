#!/bin/bash
yum update -y
yum install -y httpd
cat <<EOF > /var/www/html/index.html
<html>
<h2>Hello from the the ${server_name}</h2>
</html>
EOF

sudo systemctl start httpd
sudo systemctl enable httpd

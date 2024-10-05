#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

yum update -y
yum install -y telnet
amazon-linux-extras install nginx1 -y

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

telnet_output=$(echo quit | telnet $(aws ssm get-parameter --name "DB_HOST" --with-decryption --query "Parameter.Value" --output text --region us-east-1) 3306 2>&1)

# Save the telnet output to a file
echo "$telnet_output" > /usr/share/nginx/html/telnet_output.txt

# Set up the Nginx HTML page to show MariaDB access information and telnet output
echo "<html>
<head>
    <title>Welcome to MayBank EC2 Server</title>
</head>
<body>
    <h1>Welcome to MayBank EC2 Server!</h1>
    <h2>MariaDB Information</h2>
    <p><strong>Database Host:</strong> ${DB_HOST}</p>
    <p><strong>Database Port:</strong> ${DB_PORT}</p>
    <h2>Telnet Output:</h2>
    <pre>$(cat /usr/share/nginx/html/telnet_output.txt)</pre>
</body>
</html>" > /usr/share/nginx/html/index.html

cat <<EOT > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;

    # Root directory for serving HTML
    root /usr/share/nginx/html;

    # Serve index.html at the /api path
    location /api {
        rewrite ^/api/?$ /index.html break;
    }
}
EOT

systemctl reload nginx

# Allow Nginx traffic on port 80
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
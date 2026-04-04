#==============================================================================
# 脚本名称: docker-compose.sh
# 描述: Docker Compose 全栈应用项目
# 作者: 钟文豪
# 创建日期: 2025-05-06
# 版本: 1.0
mkdir ~/web-app
cd ~/web-app
compose文件
cat > docker-compose.yml << EOF
services:
  frontend:
    image: nginx:1.20
    ports:
      - "80:80"
    volumes:
      - ./frontend/html:/usr/share/nginx/html
      - ./frontend/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    image: backend-app
    environment:
      NODE_ENV: production
      DB_HOST: database
      DB_USER: appuser
      DB_PASSWORD: apppass
      DB_NAME: appdb
    depends_on:
      - database
    networks:
      - app-network
    ports:
      - "3000:3000"

  database:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: appdb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppass
      # 添加字符集配置
      MYSQL_CHARSET: utf8mb4
      MYSQL_COLLATION: utf8mb4_unicode_ci
    command: 
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
      - --skip-character-set-client-handshake
    volumes:
      - db-data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
EOF
创建后端应用文件
mkdir -p backend
## backend/Dockerfile
cat > backend/Dockerfile << EOF
FROM node:14

WORKDIR /app

COPY package.json ./
RUN npm install

COPY server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
EOF

## backend/package.json
cat > backend/package.json << EOF
{
  "name": "backend-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "mysql2": "^3.6.0"
  }
}
EOF

## backend/server.js
cat > backend/server.js << EOF
const http = require('http');
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10
});

const server = http.createServer(async (req, res) => {
  if (req.url === '/api/data' && req.method === 'GET') {
    try {
      const [rows] = await pool.execute('SELECT * FROM users');
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(rows));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    }
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'Not Found' }));
  }
});

server.listen(3000, () => {
  console.log('Backend running on port 3000');
});
EOF

数据库初始化脚本
mkdir -p database
cat > database/init.sql << EOF
# 设置数据库默认字符集
CREATE DATABASE IF NOT EXISTS appdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE appdb;

# 设置连接字符集
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (name, email) VALUES
('zhangsan', 'zhangsan@example.com'),
('lisi', 'lisi@example.com');
EOF

前端配置
mkdir -p frontend/html
cat > frontend/nginx.conf << EOF
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://backend:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

前端页面
cat > frontend/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>全栈应用</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .user { padding: 10px; background: #eee; margin: 5px; }
    </style>
</head>
<body>
    <h1>全栈应用</h1>
    <div id="users"></div>
    <script>
        fetch('/api/data')
            .then(r => r.json())
            .then(users => {
                let div = document.getElementById('users');
                users.forEach(u => {
                    div.innerHTML += "<div class='user'><b>" + u.name + "</b> (" + u.email + ")</div>";
                });
            });
    </script>
</body>
</html>
EOF



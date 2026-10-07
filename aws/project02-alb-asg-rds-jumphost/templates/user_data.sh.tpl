#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd

cat > /var/www/html/index.php <<'PHPCODE'
<?php
$host = '${rds_endpoint}';
$user = '${rds_username}';
$pass = '${rds_password}';
$db   = '${rds_dbname}';

$conn = new mysqli($host, $user, $pass, $db);

$hostname = gethostname();
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>App</title></head>
<body>
  <h1>Hello from <?php echo htmlspecialchars($hostname); ?></h1>
  <p>This vm is from Auto Scaling Group.</p>

<?php
if ($conn->connect_error) {
    echo "<p style='color:red'>Erro de conexao com o banco: " . htmlspecialchars($conn->connect_error) . "</p>";
} else {
    echo "<h2>Database connection OK</h2>";
    echo "<p>Host: " . htmlspecialchars($host) . "</p>";
    echo "<p>Database: " . htmlspecialchars($db) . "</p>";

    $result = $conn->query("SELECT VERSION() AS version");
    $row    = $result->fetch_assoc();
    echo "<p>Versao do banco: " . htmlspecialchars($row['version']) . "</p>";

    $conn->close();
}
?>
</body>
</html>
PHPCODE

systemctl start httpd
systemctl enable httpd
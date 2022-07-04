
[Intptr]::size
$PSVersionTable

#Installing a module
Install-Module mysqlcmdlets
Get-InstalledModule mysqlcmdlets
Import-Module mysqlcmdlets



#DB credentials
$database = ""
$user = ""
$password = ""
$server = ""
$port = ""

#MYSQL Connection
$mysql = Connect-Mysql -user "$user" -password "$password" -database "$database" -server "$server" -port "$port"

Get-Help invoke-mysql

Write-Output $mysql.GetTables()

$tables = Invoke-mysql -connection $mysql -query "select table_name from information_schema.tables where table_schema='mycakediary'"
$tables

$products = Invoke-mysql -connection $mysql -query "SELECT * FROM store_product"
$products

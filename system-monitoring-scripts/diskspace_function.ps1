function get-myDiskInfo {
param (
[Parameter(Mandatory=$true, Valuefrompipelinebypropertyname=$true, valuefrompipeline=$true, position=0)]
$computerName
)
 Begin
    {
    $data = New-Object System.Collections.ArrayList   #Creates list at the start
   }
    Process #Works through all values passed to the function
    {

$dev = Get-Wmiobject -query "select * from win32_operatingsystem" -computername $computername | Select-Object -ExpandProperty Systemdevice
$disk = Get-Wmiobject -query "select * from win32_logicaldisk where drivetype=3" -computername $computername |
Select-Object -property DeviceID, Size, Freespace 

$props = @{
"HardDisk"=$dev
"DeviceID" = $Disk.DeviceID
"Disksize" = $Disk.Size
"FreeSpace" = $Disk.Freespace
}
$obj = New-Object -TypeName PSObject -property $props
$data.add($obj) 
}End{
$data | Export-csv "C:\Users\user\Documents\powershell\disk_space_function\disk_space_$(get-date -f yyyy-MM-dd).csv" -NoTypeInformation
#Cleans up once at the end
}
}


#Testing the function
$servers = @("DESKTOP-6LU10IA", "DESKTOP-6LU10IA")
$servers | get-myDiskInfo 
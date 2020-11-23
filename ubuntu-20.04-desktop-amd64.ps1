
# Setting the PowerShell Execution Policy
# https://www.mssqltips.com/sqlservertip/2702/setting-the-powershell-execution-policy/

# Set some variables
$env:path = "C:\Program Files\Oracle\VirtualBox;$env:path"

$vmName = "ubuntu-20.04-desktop-amd64"
$osType = "Ubuntu_64" 
$vmPath = "$home\VirtualBox VMs"
$vmDiskName = "$vmName.vdi"
$vmDiskPath = "$vmPath\$vmName\$vmDiskName"
$isoFile = "$home\ISO\ubuntu-20.04.1-desktop-amd64.iso"
$username = "usuario"
$password = "usuario"
$diskSikze = 30720
$diskFormat = "VDI"
$country = "ES"
$languageCode = "es-ES"
$timezone = "UTC"
$hostname = "$vmName.jesusamieiro.com"
$sharedFolder = "$home\code"
$sharedFolderName = "code"

# Remove previous identical VM
VBoxManage controlvm $vmName poweroff
VBoxManage unregistervm $vmName --delete
Remove-Item -recurse $vmPath\$vmName

# Create the virtual machine
VBoxManage createvm `
    --name $vmName `
    --ostype $osType `
    --register `
    --basefolder $vmPath

# Enable APIC
VBoxManage modifyvm $vmName `
    --ioapic on

# Set the RAM and the video memory
VBoxManage modifyvm $vmName `
    --memory 2048 `
    --vram 128

# Set the network interface
VBoxManage modifyvm $vmName `
    --nic1 nat

# Set the virtual cores
VBoxManage modifyvm $vmName `
    --cpus 2

# Create the virtual hard disk 
# Add a SATA controller to the machine 
# Assign the hard disk to that controller
VBoxManage createhd `
    --filename "$vmDiskPath" `
    --size $diskSikze `
    --format $diskFormat
VBoxManage storagectl $vmName `
    --name "SATA Controller" `
    --add sata `
    --controller IntelAhci
VBoxManage storageattach $vmName `
    --storagectl "SATA Controller" `
    --port 0 `
    --device 0 `
    --type hdd `
    --medium "$vmPath\$vmName\$vmDiskName"

# Create an IDE driver for the DVD 
#Assign the ISO image for the installation
VBoxManage storagectl $vmName `
    --name "IDE Controller" `
    --add ide `
    --controller PIIX4
VBoxManage storageattach $vmName `
    --storagectl "IDE Controller" `
    --port 1 `
    --device 0 `
    --type dvddrive `
    --medium "$isoFile"

# Specify the location of the shared folder in the host
VBoxManage sharedfolder add $vmName `
    --name $sharedFolderName `
    --hostpath $sharedFolder `
    --automount

# Enable cliboard content sharing
VBoxManage modifyvm  $vmName `
    --clipboard-mode bidirectional

# Specifies the use of a graphics controller
VBoxManage modifyvm  $vmName `
    --graphicscontroller vboxsvga

# Set the boot order
VBoxManage modifyvm `
    $vmName --boot1 dvd `
    --boot2 disk `
    --boot3 none `
    --boot4 none

# Run the unattended installation 
VBoxManage unattended install $vmName `
    --user=$username `
    --password=$password  `
    --country=$country `
    --time-zone=$timezone `
    --hostname=$hostname `
    --iso="$isoFile" `
    --start-vm=gui `
    --locale="es_ES" `
    --language=$languageCode `
    --install-additions `

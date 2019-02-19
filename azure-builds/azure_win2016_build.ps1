$azurepackerdata = [ordered]@{
    client_id                           = (Read-Host -Prompt "Enter the client_id")
    client_secret                       = (Read-Host -Prompt "Enter the client_secret")
    tenant_id                           = (Read-Host -Prompt "tenant_id")
    subscription_id                     = (Read-Host -Prompt "Enter the subscription_id")
    managed_image_resource_group_name   = (Read-Host -Prompt "Enter the resource_group_name")
    managed_image_storage_account_type  = "Standard_LRS" # https://docs.microsoft.com/en-us/cli/azure/disk?view=azure-cli-latest
    os_type                             = "Windows" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    image_publisher                     = "MicrosoftWindowsServer" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    image_offer                         = "WindowsServer" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    winrm_username                      = "packeradmin"
    location                            = "East US 2"
    vm_size                             = "Standard_F1"
}

# Build 2016 Datacenter GUI
Write-Output "Building Azure Datacenter GUI Template"
Start-Process 'packer' -ArgumentList "build -var `"client_id=$($azurepackerdata.client_id)`" -var `"client_secret=$($azurepackerdata.client_secret)`" -var `"tenant_id=$($azurepackerdata.tenant_id)`" -var `"subscription_id=$($azurepackerdata.subscription_id)`" -var `"managed_image_resource_group_name=$($azurepackerdata.managed_image_resource_group_name)`" -var `"managed_image_storage_account_type=$($azurepackerdata.managed_image_storage_account_type)`" -var `"os_type=$($azurepackerdata.os_type)`" -var `"image_publisher=$($azurepackerdata.image_publisher)`" -var `"image_offer=$($azurepackerdata.image_offer)`" -var `"winrm_username=$($azurepackerdata.winrm_username)`" -var `"location=$($azurepackerdata.location)`" -var `"vm_size=$($azurepackerdata.vm_size)`" -var `"image_sku=2016-Datacenter`" .\azure_2016std.json" -Wait -NoNewWindow

# Build 2016 Datacenter Core
Write-Output "Building Azure Datacenter Core Template"
Start-Process 'packer' -ArgumentList "build -var `"client_id=$($azurepackerdata.client_id)`" -var `"client_secret=$($azurepackerdata.client_secret)`" -var `"tenant_id=$($azurepackerdata.tenant_id)`" -var `"subscription_id=$($azurepackerdata.subscription_id)`" -var `"managed_image_resource_group_name=$($azurepackerdata.managed_image_resource_group_name)`" -var `"managed_image_storage_account_type=$($azurepackerdata.managed_image_storage_account_type)`" -var `"os_type=$($azurepackerdata.os_type)`" -var `"image_publisher=$($azurepackerdata.image_publisher)`" -var `"image_offer=$($azurepackerdata.image_offer)`" -var `"winrm_username=$($azurepackerdata.winrm_username)`" -var `"location=$($azurepackerdata.location)`" -var `"vm_size=$($azurepackerdata.vm_size)`" -var `"image_sku=2016-Datacenter-Server-Core`" .\azure_2016core.json" -Wait -NoNewWindow

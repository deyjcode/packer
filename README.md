# Packer Image Builds for Vagrant And Azure

## Description
This repository will build images using Packer.

### What is Packer

`Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.`

### Supported Windows Boxes

* Server 2012 R2 Standard Core
* Server 2012 R2 Standard
* Server 2016 Standard Core
* Server 2016 Standard

### Usage for Vagrant

*This assumes Packer binary is in $PATH.*

1. Open a PowerShell console to the directory where the .json file is located.

2. At the command line, validate the packer image (for a 2016 Image):

```powershell
packer build .\vagrant-builds\vagrant_cloud_validate.ps1 -BoxUser deyjcode -OperatingSystem Win2012R2Core -EnableVagrantCloud -Verbose
```

3. At the command line, build the packer image (for a 2016 Image):

```powershell
packer build .\vagrant-builds\vagrant_cloud_build.ps1 -BoxUser deyjcode -OperatingSystem Win2012R2Core -EnableVagrantCloud -Verbose
```

4. If you plan on utilizing Vagrant Cloud, ensure that $VAGRANT_CLOUD_TOKEN is located in your Environment variables with the Cloud API Token. 
    * [Feel free to use my PowerShell module to interface with the Vagrant Cloud API](https://github.com/deyjcode/PSVagrantCloud)!

#### Technical Details for Vagrant

* provider: `virtualbox-iso`
* communicator: `winrm`
* software installed:
    * `chocolatey`
    * `7-zip`
    * `virtual-box guest additions`
* [generalized sysprep](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation)
* Box Hardware:
    * vCPUs: 2
    * Memory: 4096

### Usage for Azure Images

*This assumes Packer binary is in $PATH.*

#### Create a Service Principal

```powershell
# Powershell:
$sp = New-AzureRmADServicePrincipal -DisplayName "SPN User" `
    -Password (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force)
Sleep 20
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ApplicationId
```

Note the values in a secure location. Prepare them for the following steps:

#### Run the PowerShell validation/build scripts

1. Open a PowerShell console to the directory `.\azure-builds\`

2. At the command line, validate the packer image (for a 2016 Image):

```powershell
.\azure-builds\azure_win2016_validate.ps1
```

3. At the command line, build the packer image (for a 2016 Image):

```powershell
.\azure-builds\azure_win2016_build.ps1
```

Alternatively, place these values environment variables `$env:azure_client_id` instead.

#### Technical Details for Azure

* provider: `azure-arm`
* communicator: `winrm`
* Size: `Standard_F1`
* software installed:
    * Ansible for Windows Remoting (https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1)

Otheriwse standard image sku provided by Microsoft.
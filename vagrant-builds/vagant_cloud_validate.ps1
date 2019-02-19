<# 
Checks the template is valid by parsing the template and also
checking the configuration with the various builders, provisioners, etc.

If it is not valid, the errors will be shown and the command will exit
with a non-zero exit status. If it is valid, it will exit with a zero
exit status.

AUTHOR: steven jennings <steven@automatingops.com>

#>

[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Prepends Data before the Operating System for publishing"
        )]
    [string]$BoxUser,

    [ValidateSet("Win2012R2Std", "Win2012R2Core", "Win2016Core", "Win2016Std")]
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Valid Values: Win2012R2Std, Win2012R2Core, Win2016Core, Win2016Std"
        )]
    $OperatingSystem,
    [switch]$EnableVagrantCloud
)

Begin {

    # Check if Environment Variable is present to upload to Vagrant Cloud
    if ($EnableVagrantCloud.IsPresent) {
        $VagrantCloudTokenPath = Test-Path -Path Env:\VAGRANT_CLOUD_TOKEN
        if ($VagrantCloudTokenPath -eq $false) {
            Write-Error "A Vagrant Cloud Token must exist in the environment variable VAGRANT_CLOUD_TOKEN"
            exit
        }
    }

    # Checksum Values 
    $ChecksumAlgorithm = "MD5"

    $Win2012MD5Checksum = "5B5E08C490AD16B59B1D9FAB0DEF883A"
    $Win2016MD5Checksum = "70721288bbcdfe3239d8f8c0fae55f1f"

    # ISO URLs
    $Win2012ISOURL = "http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"
    $Win2016ISOURL = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

    # Create boxtag for Vagrant Cloud if needed
    $BoxTag = "$BoxUser/$OperatingSystem"
}

Process {
    $floppyfiles = @{
        floppyfile1 = "./answer_files/$OperatingSystem/autounattend.xml"
        floppyfile2 = "./answer_files/$OperatingSystem/shutdown.xml"
    }

    switch -Wildcard ($OperatingSystem) {
        'Win2012R2*' {
            $packerdata = @{
                name              = $BoxUser
                template          = "windowsserver"
                iso_url           = $Win2012ISOURL
                iso_checksum      = $Win2012MD5Checksum
                iso_checksum_type = $ChecksumAlgorithm
                guest_os_type     = "Windows2012_64"
            }
            if ($EnableVagrantCloud.IsPresent) {
                $vagrantclouddata = @{
                    box_tag             = $BoxTag
                    vagrant_cloud_token = $env:VAGRANT_CLOUD_TOKEN
                }
                $packerdata += $vagrantclouddata
            }
        }

        'Win2016*' {
            $packerdata = @{
                name              = $BoxUser
                template          = "windowsserver"
                iso_url           = $Win2016ISOURL
                iso_checksum      = $Win2016MD5Checksum
                iso_checksum_type = $ChecksumAlgorithm
                guest_os_type     = "Windows2016_64"
            }
            if ($EnableVagrantCloud.IsPresent) {
                $vagrantclouddata = @{
                    box_tag             = $BoxTag
                    vagrant_cloud_token = $env:VAGRANT_CLOUD_TOKEN
                }
                $packerdata += $vagrantclouddata
            }
        }
    }

    # Add floppy files
    $packerdata += $floppyfiles
    
    if ($EnableVagrantCloud.IsPresent) {
        # Upload box to Vagrant Cloud if switch is present
        Start-Process 'packer' -ArgumentList "validate -var `"name=$($packerdata.name)`" -var `"template=$($packerdata.template)`" -var `"iso_url=$($packerdata.iso_url)`" -var `"iso_checksum=$($packerdata.iso_checksum)`" -var `"iso_checksum_type=$($packerdata.iso_checksum_type)`" -var `"box_tag=$($packerdata.box_tag)`" -var `"box_tag=$($packerdata.vagrant_cloud_token)`" -var `"floppyfile1=$($packerdata.floppyfile1)`" -var `"floppyfile2=$($packerdata.floppyfile2)`" -var `"guest_os_type=$($packerdata.guest_os_type)`" .\win_vagrantcloud_build.json" -Wait -NoNewWindow
    }
    else {
        Start-Process 'packer' -ArgumentList "validate -var `"name=$($packerdata.name)`" -var `"template=$($packerdata.template)`" -var `"iso_url=$($packerdata.iso_url)`" -var `"iso_checksum=$($packerdata.iso_checksum)`" -var `"iso_checksum_type=$($packerdata.iso_checksum_type)`" -var `"floppyfile1=$($packerdata.floppyfile1)`" -var `"floppyfile2=$($packerdata.floppyfile2)`" -var `"guest_os_type=$($packerdata.guest_os_type)`" .\win_local_build.json" -Wait -NoNewWindow
    }
}

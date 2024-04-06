terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

resource "coder_script" "windows-rdp" {
  agent_id     = var.agent_id
  display_name = "web-rdp"
  icon         = "https://svgur.com/i/158F.svg" # TODO: add to Coder icons
  script       = <<EOF
  function Set-AdminPassword {
      param (
          [string]$adminPassword
      )
      # Set admin password
      Get-LocalUser -Name "Administrator" | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText $adminPassword -Force)
      # Enable admin user
      Get-LocalUser -Name "Administrator" | Enable-LocalUser
  }

  function Configure-RDP {
      # Enable RDP
      New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -PropertyType DWORD -Force
      # Disable NLA
      New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -PropertyType DWORD -Force
      New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 1 -PropertyType DWORD -Force
      # Enable RDP through Windows Firewall
      Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
  }

  function Install-DevolutionsGateway {
    # Define the module name and version
    $moduleName = "DevolutionsGateway"
    $moduleVersion = "2024.1.5"

    # Install the module with the specified version for all users
    # This requires administrator privileges
    Install-Module -Name $moduleName -RequiredVersion $moduleVersion -Force

    # Construct the module path for system-wide installation
    $moduleBasePath = "C:\Windows\system32\config\systemprofile\Documents\PowerShell\Modules\$moduleName\$moduleVersion"
    $modulePath = Join-Path -Path $moduleBasePath -ChildPath "$moduleName.psd1"

    # Import the module using the full path
    Import-Module $modulePath
    Install-DGatewayPackage

    # Configure Devolutions Gateway
    $Hostname = "localhost"
    $HttpListener = New-DGatewayListener 'http://*:7171' 'http://*:7171'
    $WebApp = New-DGatewayWebAppConfig -Enabled $true -Authentication None
    $ConfigParams = @{
      Hostname = $Hostname
      Listeners = @($HttpListener)
      WebApp = $WebApp
    }
    Set-DGatewayConfig @ConfigParams
    New-DGatewayProvisionerKeyPair -Force

    # Configure and start the Windows service
    Set-Service 'DevolutionsGateway' -StartupType 'Automatic'
    Start-Service 'DevolutionsGateway'
  }

  Set-AdminPassword -adminPassword "coderRDP!"
  Configure-RDP
  Install-DevolutionsGateway

  EOF

  run_on_start = true
}

resource "coder_app" "windows-rdp" {
  agent_id     = var.agent_id
  slug         = "web-rdp"
  display_name = "Web RDP"
  url          = "http://localhost:7171"
  icon         = "https://svgur.com/i/158F.svg"
  subdomain    = true

  healthcheck {
    url       = "http://localhost:${var.port}"
    interval  = 5
    threshold = 15
  }
}

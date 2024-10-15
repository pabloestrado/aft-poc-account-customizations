{
 "schemaVersion": "2.2",
  "description": "Disable auto update OS",
  "parameters": {},
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "example",
      "inputs": {
        "runCommand": [
          "sudo sed -i '/^APT::Periodic::Update-Package-Lists /cAPT::Periodic::Update-Package-Lists \"0\"\\;' /etc/apt/apt.conf.d/20auto-upgrades",
          "sudo sed -i '/^APT::Periodic::Unattended-Upgrade /cAPT::Periodic::Unattended-Upgrade \"0\"\\;' /etc/apt/apt.conf.d/20auto-upgrades",
          "sudo sed -i '/^APT::Periodic::Update-Package-Lists /cAPT::Periodic::Update-Package-Lists \"0\"\\;' /etc/apt/apt.conf.d/10periodic",
          "sudo sed -i '/^APT::Periodic::Download-Upgradeable-Packages /cAPT::Periodic::Download-Upgradeable-Packages \"0\"\\;' /etc/apt/apt.conf.d/10periodic",
          "sudo sed -i '/^APT::Periodic::AutocleanInterval /cAPT::Periodic::AutocleanInterval \"0\"\\;' /etc/apt/apt.conf.d/10periodic"
        ]
      }
    }
  ]
}
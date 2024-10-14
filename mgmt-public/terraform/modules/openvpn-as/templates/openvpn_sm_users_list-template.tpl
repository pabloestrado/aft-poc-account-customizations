{
  "schemaVersion": "2.2",
  "description": "Create a list of OpenVPN users",
  "parameters": {},
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "example",
      "inputs": {
        "runCommand": [
          "cd /usr/local/openvpn_as/scripts",
          "sudo echo 'Account_ID:' > info.txt",
          "sudo aws sts get-caller-identity | grep '\"Account\":.*\"' | tr -d '\"Account\":, ' >> info.txt",
          "sudo echo 'Instance_Hostname:' >> info.txt",
          "sudo ec2metadata --public-hostname >> info.txt",
          "sudo echo 'Instance_ID:' >> info.txt",
          "sudo ec2metadata --instance-id >> info.txt",
          "sudo echo 'Instance_IP:' >> info.txt",
          "sudo ec2metadata --public-ipv4 >> info.txt",
          "sudo echo 'VPN_Users:' >> info.txt",
          "sudo ./sacli UserPropGet | grep '\".*\":.{' | tr -d ' \":{' >> info.txt",
          "message=`cat info.txt | tr '\n' ' '`",
          "curl --location --request POST '${api_url}' --header 'Content-Type: application/json' --data '{\"message\":\"'\"$message\"'\"}'",
          "sudo rm info.txt"
        ]
      }
    }
  ]
}
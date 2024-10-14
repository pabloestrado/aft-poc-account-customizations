{
    "schemaVersion": "2.2",
    "description": "Execute OpenVPN CLI commands.",
    "parameters": {},
    "mainSteps": [
        {
            "action": "aws:runShellScript",
            "name": "example",
            "inputs": {
                "runCommand": [
                    "until systemctl is-active --quiet openvpnas.service; do echo 'Waiting to start Openvpn service'; done",
                    "cd /usr/local/openvpn_as/scripts",
                    "sudo ./sacli --user __DEFAULT__ --key prop_autologin --value true UserPropPut",
                    %{ for index, subnet in subnets }
                    "sudo ./sacli --key \"vpn.server.routing.private_network.${index+1}\" --value \"${subnet}\" ConfigPut",
                    %{ endfor }
                    "sudo ./sacli --key \"admin_ui.https.port\" --value \"${admin_port}\" ConfigPut",
                    "sudo ./sacli --key \"host.name\" --value \"${eip}\" ConfigPut",
                    "sudo ./sacli start"
                ]
            }
        }
    ]
}

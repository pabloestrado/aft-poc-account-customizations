{
    "schemaVersion": "2.2",
    "description": "Certbot configuration for OpenVPN",
    "parameters": {},
    "mainSteps": [
        {
            "action": "aws:runShellScript",
            "name": "example",
            "inputs": {
                "runCommand": [
                    "sudo snap install --classic certbot",
                    "sudo ln -s -f /etc/letsencrypt/live/vpn.${project_domain}/fullchain.pem /usr/local/openvpn_as/etc/web-ssl/server.crt",
                    "sudo ln -s -f /etc/letsencrypt/live/vpn.${project_domain}/privkey.pem /usr/local/openvpn_as/etc/web-ssl/server.key",
                    "sudo ln -s -f /etc/letsencrypt/live/vpn.${project_domain}/chain.pem /usr/local/openvpn_as/etc/web-ssl/ca.crt",
                    "sudo crontab -l | { cat; echo '0 0 1 * *  sudo /snap/bin/certbot certonly -d vpn.${project_domain}  --pre-hook \"sudo service openvpnas stop\"  --post-hook \"sudo service openvpnas start\"  --force-renewal --standalone --agree-tos  --non-interactive --email admin@vpn.${project_domain}'; } | sudo crontab -",
                    "sudo /snap/bin/certbot certonly -d vpn.${project_domain} --pre-hook \"sudo service openvpnas stop\"  --post-hook \"sudo service openvpnas start\"  --force-renewal --standalone --agree-tos  --non-interactive --email admin@vpn.${project_domain}",
                    "sudo ./sacli start"
                ]
            }
        }
    ]
}

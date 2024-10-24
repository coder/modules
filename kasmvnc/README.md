---
display_name: KasmVNC
description: A modern open source VNC server
icon: ../.icons/kasmvnc.svg
maintainer_github: coder
verified: true
tags: [helper, vnc, desktop]
---

# KasmVNC

Automatically install [KasmVNC](https://kasmweb.com/kasmvnc) in a workspace, and create an app to access it via the dashboard.

```tf
module "kasmvnc" {
  source              = "registry.coder.com/modules/kasmvnc/coder"
  version             = "1.0.23"
  agent_id            = coder_agent.example.id
  desktop_environment = "xfce"
}
```

> **Note:** This module only works on workspaces with a pre-installed desktop environment. As an example base image you can use `codercom/enterprise-desktop` image.

> **Note:** You can also use the kasmtech [custom images](https://kasmweb.com/docs/latest/guide/custom_images.html) by extending them as following:

```Dockerfile
FROM kasmweb/postman:1.16.0
ARG USER=kasm-user
USER root
# Overwrite the existing config file to disable ssl
RUN cat <<EOF > /etc/kasmvnc/kasmvnc.yaml
network:
  protocol: http
  ssl:
    require_ssl: false
  udp:
    public_ip: 127.0.0.1
EOF
RUN addgroup $USER ssl-cert
USER $USER
```

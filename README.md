# ollama_webui_public
the publicly available docker image containing ollama + webui + authentication proxy

## Setup Guide

### Preprequisites

Configure an `ubuntu` server

The configured server should allow `IPv4` networking to pull configuration files from Github. Github does not support `IPv6`, so if your server has `IPv6` netwok only, then you won't be able to work with the Github

Following ports should be open in the firewall to enable HTTP and HTTPS access:

- `80` — for HTTP access for ACME/Letsencrypt to be configured successfull
- `443` — to make services accessible via `https`

By default the services are configured with following endpoints

| service | endpoints |
|------|-----------|
| Ollama | `ollama.example.com` |
| Open WebUI | `open-webui.example.com` |
| Auth | `auth.example.com` |

#### Short prerequisites checklist checklist:

- Make sure that `IPv4` is available on your server
- Create a DNS `A` records according to table above
- Open port TCP IPv4 `80` in Firewall
- Open port TCP IPv4 `443` in Firewall
- Open TCP IPv4 ports `10000-65535`

### Download setup scripts

First into the server. You can access it by the one of the configured DNS `A` records. If you've configured `ssh` to be accessed on a port different than defaul `22`, then add `-p <your_port>` to the command below

```shell
ssh root@SERVER_IP -p SERVER_SSH_PORT
```

Clone current repository:

```shell
git clone https://github.com/cdilcher/ollama_webui_public.git
```

### Installation

Navigate to Ollama installation scripts location, give execution permission to `server_config.sh` script and execute it to install everything that is required to run the Ollama service

```shell
cd ollama_webui_public
chmod +x server_config.sh
./server_config.sh
```

This will install Docker on your machine, install NVidia drivers and download required docker images and create required folders.

Once the setup process is complete you will see following message in your terminal window:

```shell
"##################################################"
"# Setup Complete!                                #"
"# Please reboot server to enable NVidia drivers  #"
"##################################################"
```

After that reboot the server

```shell
reboot
```

### Optional: Using custom URL address for ChromaDB

> Skip this step if you are using default `api.chroma.embeddings.sx` endpoint for this service

To use custom endpoint an `nginx` config file should be modified. Open `proxy_443.conf` file with your favorite text editor:

```shell
nano ./ollama/user_conf.d/proxy_443.conf
```

##### Open WebUI address

Find line `7` which looks following:

```shell
    server_name open-webui.example.com;
```

Replace `open-webui.example.com` with your custom URL address, for example

```shell
    server_name your.custom.open-webui.address.com;
```

##### Auth server address

Find line `28` which looks following:

```shell
    server_name auth.example.com;
```

Replace `auth.example.com` with your custom URL address, for example

```shell
    server_name your.custom.auth.address.com;
```

##### Ollama API address

Find line `52` which looks following:

```shell
    server_name ollama.example.com;
```

Replace `ollama.example.com` with your custom URL address, for example

```shell
    server_name your.custom.ollama.address.com;
```

Save changes and close the editor.


### Starting the service

Run docker compose command in detached mode

```shell
docker compose up -d
```

You might need to wait a little on the first launch to generate Let's Encrypt certificates.

Check [https://open-webui.example.com](https://open-webui.example.com) endpoint to access Open WebUI interface. Once the page successfully loads, service is completely up and running

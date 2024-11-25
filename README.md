# fcos-rpi

A [Fedora CoreOS](https://docs.fedoraproject.org/en-US/fedora-coreos/getting-started/) setup for Raspberry Pi 4.

This is a Butane configuration for my personal DNS sinkholing setup that contains the following:

-   [Adguard Home](https://adguard.com/en/adguard-home/overview.html)
-   [Cloudflare Tunnels](https://www.cloudflare.com/products/tunnel/)
-   [Tailscale](https://tailscale.com/)

There's also a [`justfile`](./justfile) for automating the reprovisioning of the Pi.

On the Pi, everything is run as containers with `podman` adapted from:

-   [Adguard Home Docker guide](https://github.com/AdguardTeam/AdGuardHome/wiki/Docker)
-   [Cloudflared Docker image](https://hub.docker.com/r/cloudflare/cloudflared)
-   [Tailscale Docker guide](https://tailscale.com/kb/1282/docker)

To preserve Adguard Home configuration, `/var/` is made persistent. Read more:

-   https://docs.fedoraproject.org/en-US/fedora-coreos/storage/
-   https://docs.fedoraproject.org/en-US/fedora-coreos/live-booting/#_using_persistent_state
-   https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/#_destination_drive

Cloudflare Tunnels are remotely managed and used to expose the Adguard Home dashboard to whitelisted IPs and the DNS-over-HTTPS servers to the public internet for usage from everywhere. Adguard Home is configured to allow unencrypted DoH requests, since the encryption is done on Cloudflare's side. Read more:

-   https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/
-   https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/remote-management/

Tailscale is included solely to enable using Adguard Home as the default DNS resolver for my whole Tailnet. This will no longer be necessary once this issue is completed:

-   https://github.com/tailscale/tailscale/issues/74

Secrets are supplied to the generated `config.ign` with `envsubst`. This requires a `.env` file exporting these variables:

-   `SSH_PUBKEY` (for SSH access to the RPi)
-   `CLOUDFLARE_TOKEN` (for a remotely managed Cloudflare Tunnel)
-   `TAILSCALE_AUTH_KEY` (to add the device to the tailnet)

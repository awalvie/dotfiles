#!/usr/bin/env bash
# Docker setup that Nix can't manage on a non-NixOS host (root daemon, systemd
# unit, apt repo, group membership ≈ root). Installs Docker Engine from
# Docker's official apt repo, enables the daemon, and puts the user in the
# docker group. Idempotent — no-op once docker is installed, running, and the
# user is in the group.
# Called by home-manager activation OR runnable standalone.
#
# Usage: setup-docker.sh <user>

set -euo pipefail

USER_NAME="${1:?missing user}"

DOCKER_GPG=/etc/apt/keyrings/docker.asc
DOCKER_LIST=/etc/apt/sources.list.d/docker.list

install_docker() {
    echo ">>> docker: installing from Docker's official apt repo (sudo required)"

    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl

    # Docker's GPG key + apt repo.
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$DOCKER_GPG"
    sudo chmod a+r "$DOCKER_GPG"

    # PopOS is Ubuntu-based; UBUNTU_CODENAME maps to a release Docker publishes
    # (VERSION_CODENAME may be a Pop-specific name Docker doesn't ship for).
    local codename arch
    codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
    arch="$(dpkg --print-architecture)"
    echo "deb [arch=${arch} signed-by=${DOCKER_GPG}] https://download.docker.com/linux/ubuntu ${codename} stable" \
        | sudo tee "$DOCKER_LIST" >/dev/null

    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable --now docker
}

ensure_group() {
    # docker-ce creates the docker group; make sure the user is in it. Reads the
    # group db (id -nG <user>), so it reflects /etc/group right after usermod —
    # but the user's interactive shells only gain the group on next login.
    if ! getent group docker >/dev/null; then
        sudo groupadd docker
    fi
    if ! id -nG "$USER_NAME" | tr ' ' '\n' | grep -qx docker; then
        echo ">>> docker: adding $USER_NAME to the docker group (re-login to take effect)"
        sudo usermod -aG docker "$USER_NAME"
    fi
}

if command -v docker >/dev/null && systemctl is-active --quiet docker; then
    echo ">>> docker: already installed and running"
else
    install_docker
fi

ensure_group
echo ">>> docker: ready"

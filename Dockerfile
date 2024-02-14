# Use the official Debian Bookworm base image
FROM debian:bookworm

# We make a fake systemctl so that incus doesn't error out without systemd
RUN echo "#!/bin/bash" > /sbin/systemctl && \
    echo "exit 0" >> /sbin/systemctl && \
    chmod +x /sbin/systemctl && \
# Install curl so we can install the keyring.
    apt-get update && \
    apt-get install -y curl && \
    mkdir -p /etc/apt/keyrings/ && \
    curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/zabbly.asc] https://pkgs.zabbly.com/incus/stable $(. /etc/os-release && echo ${VERSION_CODENAME}) main" > /etc/apt/sources.list.d/zabbly-incus-stable.list && \
# Install incus and so on
    apt-get update && \
    apt-get install -y iproute2 btrfs-progs kmod incus incus-ui-canonical && \
    apt-get remove -y curl && \
    apt autoremove -y && \
    apt-get clean

# Set environment variables
ENV PATH="/opt/incus/bin/:${PATH}"
ENV INCUS_OVMF_PATH="/opt/incus/share/qemu/"
ENV LD_LIBRARY_PATH="/opt/incus/lib/"
ENV INCUS_LXC_TEMPLATE_CONFIG="/opt/incus/share/lxc/config/"
ENV INCUS_DOCUMENTATION="/opt/incus/doc/"
ENV INCUS_LXC_HOOK="/opt/incus/share/lxc/hooks/"
ENV INCUS_AGENT_PATH="/opt/incus/agent/"
ENV INCUS_UI="/opt/incus/ui/"

# Run the incusd binary
CMD ["/opt/incus/bin/incusd"]

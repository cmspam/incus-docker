# Use the official Debian Bookworm base image
FROM debian:bookworm-slim

# We make a fake systemctl so that incus doesn't error out without systemd
RUN echo "#!/bin/bash" > /sbin/systemctl && \
    echo "exit 0" >> /sbin/systemctl && \
    chmod +x /sbin/systemctl && \
# Install curl so we can install the keyring.
    apt-get update && \
    apt-get install --no-install-recommends -y curl ca-certificates && \
    mkdir -p /etc/apt/keyrings/ && \
    curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/zabbly.asc] https://pkgs.zabbly.com/incus/stable $(. /etc/os-release && echo ${VERSION_CODENAME}) main" > /etc/apt/sources.list.d/zabbly-incus-stable.list && \
# Install incus and so on
    apt-get update && \
    apt-get install --no-install-recommends -y iproute2 btrfs-progs iptables kmod incus incus-ui-canonical && \
    apt-get remove -y curl && \
    apt autoremove -y && \
    apt-get clean && \
    echo '#!/bin/bash' > /start.sh && \
    echo 'export PATH="/opt/incus/bin/:${PATH}"' >> /start.sh && \
    echo 'export INCUS_OVMF_PATH="/opt/incus/share/qemu/"' >> /start.sh && \
    echo 'export LD_LIBRARY_PATH="/opt/incus/lib/"' >> /start.sh && \
    echo 'export INCUS_LXC_TEMPLATE_CONFIG="/opt/incus/share/lxc/config/"' >> /start.sh && \
    echo 'export INCUS_DOCUMENTATION="/opt/incus/doc/"' >> /start.sh && \
    echo 'export INCUS_LXC_HOOK="/opt/incus/share/lxc/hooks/"' >> /start.sh && \
    echo 'export INCUS_AGENT_PATH="/opt/incus/agent/"' >> /start.sh && \
    echo 'export INCUS_UI="/opt/incus/ui/"' >> /start.sh && \
    echo 'if [ "$SETIPTABLES" = "true" ]; then' >> /start.sh && \
    echo 'if ! iptables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'iptables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'if ! ip6tables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'ip6tables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'if ! iptables -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'iptables -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'if ! ip6tables -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'ip6tables -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '/opt/incus/bin/incusd' >> /start.sh && \
    chmod +x /start.sh

# Set environment variables
#ENV PATH="/opt/incus/bin/:${PATH}"
#ENV INCUS_OVMF_PATH="/opt/incus/share/qemu/"
#ENV LD_LIBRARY_PATH="/opt/incus/lib/"
#ENV INCUS_LXC_TEMPLATE_CONFIG="/opt/incus/share/lxc/config/"
#ENV INCUS_DOCUMENTATION="/opt/incus/doc/"
#ENV INCUS_LXC_HOOK="/opt/incus/share/lxc/hooks/"
#ENV INCUS_AGENT_PATH="/opt/incus/agent/"
#ENV INCUS_UI="/opt/incus/ui/"

# Run the incusd binary
CMD ["/start.sh"]

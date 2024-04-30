# Use the official Debian Bookworm base image
FROM docker.io/debian:bookworm

RUN echo "deb http://deb.debian.org/debian bookworm contrib" >> /etc/apt/sources.list && \
# Install curl so we can install the keyring.
    apt-get update && \
    apt-get install --no-install-recommends -y curl ca-certificates && \
    mkdir -p /etc/apt/keyrings/ && \
    curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/zabbly.asc] https://pkgs.zabbly.com/incus/stable $(. /etc/os-release && echo ${VERSION_CODENAME}) main" > /etc/apt/sources.list.d/zabbly-incus-stable.list && \
# Install systemd, incus, and dependencies
    apt-get update && \
    apt-get install --no-install-recommends -y iproute2 thin-provisioning-tools openvswitch-switch btrfs-progs zfsutils-linux lvm2 udev iptables kmod incus incus-ui-canonical bash apt-utils bash-completion bc bzip2 curl dialog diffutils findutils gnupg gnupg2 gpgsm hostname iproute2 iputils-ping keyutils less libcap2-bin libkrb5-3 libnss-mdns libnss-myhostname libvte-2.9*-common libvte-common locales lsof man-db manpages mtr ncurses-base openssh-client passwd pigz pinentry-curses procps rsync sudo tcpdump time traceroute tree tzdata unzip util-linux wget xauth xz-utils zip libgl1 libegl1-mesa libgl1-mesa-glx libegl1 libglx-mesa0 libvulkan1 mesa-vulkan-drivers systemd libpam-systemd && \
# Enable incus
    systemctl enable incus && \
# Clean up
    apt autoremove -y && \
    apt-get clean && \
# Disable TTY
    systemctl mask getty@tty1.service && \
    systemctl mask getty@tty2.service && \
    systemctl mask getty@tty3.service && \
    systemctl mask getty@tty4.service && \
    systemctl mask getty@tty5.service && \
    systemctl mask getty@tty6.service && \
# Disable zfs load module
    systemctl mask zfs-load-module.service && \
    systemctl mask ovsdb-server.service && \
    systemctl mask ovs-vswitchd.service && \
    systemctl mask openvswitch-switch && \
    systemctl mask ovs-record-hostname && \
# Make /openvswitch directory
    mkdir /openvswitch && \
# Make systemd service to mount /run/openvswitch
    echo "[Unit]" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "Description=Mount OpenVSwitch" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "Before=network-online.target" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "Wants=network-online.target" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "[Service]" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "Type=oneshot" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "RemainAfterExit=yes" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "ExecStartPre=/bin/mkdir -p /run/openvswitch" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "ExecStart=/bin/mount --bind /openvswitch /run/openvswitch" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "ExecStop=/bin/umount /run/openvswitch" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "[Install]" >> /etc/systemd/system/mount-openvswitch.service && \
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/mount-openvswitch.service && \
    systemctl enable mount-openvswitch.service && \
# Make our startup script
    touch /sbin/entrypoint.sh && \
    chmod +x /sbin/entrypoint.sh && \
    echo "#!/bin/bash" >> /sbin/entrypoint.sh && \
# Prevent output to /dev/console, instead use log output.
    echo "mount --bind /dev/null /dev/console" >> /sbin/entrypoint.sh && \
# Mount openvswitch in /run
    echo "mkdir -p /run/openvswitch" >> /sbin/entrypoint.sh && \
    echo "mount --bind /openvswitch /run/openvswitch" >> /sbin/entrypoint.sh && \
# Our entrypoint is systemd boot.
    echo "exec /sbin/init --boot" >> /sbin/entrypoint.sh


CMD ["/sbin/entrypoint.sh"]

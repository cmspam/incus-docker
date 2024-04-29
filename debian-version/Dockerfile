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

# Our entrypoint is systemd boot.
CMD ["/sbin/init", "--boot"]

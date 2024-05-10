# incus-docker
A project to run incus in docker/podman

Incus is a fork of lxd. Please see here:
https://linuxcontainers.org/incus/

This project aims to maintain a Dockerfile to run incus in a docker/podman container.
It also installs the incus-ui-canonical to have a Web-based UI.

*Versions*
Debian version: I recommend using this with any glibc-based distributions. This is based off of zabbly/incus stable builds ( https://github.com/zabbly/incus )

*(Dockerfile-only) versions*
Alpine versions are also available, only in Dockerfile form. These will not be prioritized at present.

*Branches*
You can pull from
incus-docker:latest -- The default choice. The latest stable version of Incus
incus-docker:daily -- The daily builds from zabbly/incus
incus-docker:lts -- The 6.0 LTS version of incus.

How to use it:

*Note*: If you use the environment variable SETIPTABLES=true, it will be adding:
```
iptables (or iptables-legacy) -I DOCKER-USER -j ACCEPT
ip6tables (or ip6tables-legacy) -I DOCKER-USER -j ACCEPT
```

The reason is that, without doing this, docker's iptables settings will be blocking the connections from the incus bridge you create, and your containers/vms will not be able to access the internet. If you use podman, it's not needed.

*Note*: If you want to use LXCFS support, you can set the environment variable USELXCFS=true and mount your volume at /var/lib/lxcfs

# To use the image

First, make the directory to hold incus configuration:
``` mkdir /var/lib/incus ```


With Podman (recommended):
```
podman run -d \
--name incus \
--cgroups=no-conmon \
--cgroupns=host \
--security-opt unmask=/sys/fs/cgroup \
--privileged \
--network host \
--pid=host \
--volume /dev:/dev \
--volume /var/lib/incus:/var/lib/incus \
--volume /lib/modules:/lib/modules:ro \
ghcr.io/cmspam/incus-docker:latest
```
With Docker:

```
docker run -d \
--name incus \
--privileged \
--env SETIPTABLES=true \
--restart unless-stopped \
--network host \
--pid=host \
--volume /dev:/dev \
--volume /var/lib/incus:/var/lib/incus \
--volume /lib/modules:/lib/modules:ro \
ghcr.io/cmspam/incus-docker:latest
```

# Fixing cgroups issue

If you run 'podman logs incus' you may see an error such as
```
level=error msg="balance: Unable to set cpuset" err="setting cgroup item for the container failed"
name=(container) value="0,1,2,3"
```
This can be fixed by making sure you run with the option:
```--pid=host```

# AppArmor

If you have AppArmor enabled on your setup, you may need to add permissions to dnsmasq so that it can work with Incus without permission errors.  Here is an example of how to do so with OpenSuse Tumbleweed, but it should be similar for other distributions.

Please edit the file:
```/etc/apparmor.d/usr.sbin.dnsmasq```

You will find a line like below, for Tumbleweed it was line 56 or so:
 ```/var/log/dnsmasq*.log w,```

Under that line, please add
 ```/var/lib/incus/** rw,```


If you want to use AppArmor functionality in incus, you can pass it through to the container by adding:

```--volume /sys/kernel/security:/sys/kernel/security```

# OpenVSwitch

If you use OpenVSwitch, add this line to your docker/podman command:
```--volume /run/openvswitch:/run/openvswitch```

# Alpine-based Image

NOTE: If you are using the alpine version with a glibc-based image, you can't depend on the ability to load the modules for VMs automatically. You should set up your environment to automatically load vhost_vsock and kvm modules. You can do it like this:

```
echo "vhost_vsock" > /etc/modules-load.d/incus.conf
echo "kvm" >> /etc/modules-load.d/incus.conf
```

# Management

After you start the container, incus will be running. If you used the folder I suggested and used host networking, you can manage it immediately with the incus binary from the same machine. Grab the binary from the latest releases here:

https://github.com/lxc/incus/releases

For example, I use bin.linux.incus.x86_64 from the Assets at the above link.

You can then run **chmod +x bin.linux.incus.x86_64** to make it executable. Let's rename it to incus by running  **mv bin.linux.incus.x86_64 incus**

Now we can check it's working by running

```./incus admin init```

And we can proceed to configure incus.

I find it easiest to move the binary to /usr/local/bin so that I can just run **incus admin init** or whatever other incus command I need from PATH.

If you configure it to be manageable from the network, we can access the web UI, at https://{YOUR IP}:8443

I have successfully tested on both arm64 and x86_64, on ClearLinux (x86_64) and OpenSuse MicroOS (x86_64, arm64). If your distribution has a native Incus package, it's best to use it.

The focus is on x86_64 and arm64, but other platforms may work if you build the Alpine-based Dockerfile.

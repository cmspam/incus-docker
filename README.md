# incus-docker
A project to run incus in docker/podman

Incus is a fork of lxd. Please see here:
https://linuxcontainers.org/incus/

This project aims to maintain a Dockerfile to run incus in a docker/podman container.
It also installs the incus-ui-canonical to have a Web-based UI.

I now have made a debian-based and two alpine-based options available. However due to some issues with the alpine version, my focus going forward will be on the debian version.

The regular alpine version contains what is necessary to run both containers and VMs, but a smaller alpine-based version called alpine-novm which allows you to use contianers, but not virutal machines, to keep the image smaller, is also available. But be prepared for some various issues if you use the alpine version.

For debian, we are using the version of incus maintained here:
https://github.com/zabbly/incus

For alpine, we use the version in edge/testing -- it could be unstable.

How to use it:

*Note*: If you use the environment variable SETIPTABLES=true, it will be adding:
```
iptables-legacy -I DOCKER-USER -j ACCEPT
ip6tables-legacy -I DOCKER-USER -j ACCEPT
```

The reason is that, without doing this, docker's iptables settings will be blocking the connections from the incus bridge you create, and your containers/vms will not be able to access the internet. If you use podman, it's not needed from my testing.

*Note*: If you want to use LXCFS support, you can set the environment variable USELXCFS=true and mount your volume at /var/lib/lxcfs

*Note*: If you want to use LVM, you can pass mount /dev as /dev in the container.

*Note*: ZFS support should also be working as of 25 February, 2024 update.

# If you want to use the image from docker hub

See the instructions here:

https://hub.docker.com/r/cmspam/incus-docker

# If you want to build the Dockerfile yourself

Place the Dockerfile somewhere, and run:

``` docker build -t incus-docker ```

Then, run the docker image. It will not work unless run as privileged. You will want to provide your own /var/lib/incus directory, and to allow it to automatically load the necessary modules when launching a VM (kvm and vsock_vhost) you may also want to give it your /lib/modules directory. Finally, because of incus's networking features, you will probably want to use host networking.  Therefore, you can do something like this on first run:

``` mkdir /var/lib/incus ```

```
docker run -d \
--name incus \
--privileged \
--env SETIPTABLES=true \
--restart unless-stopped \
--device /dev/kvm \
--device /dev/vsock \
--network host \
--volume /var/lib/incus:/var/lib/incus \
--volume /lib/modules:/lib/modules:ro \
incus-docker
```

or for podman

```
podman run -d \
--name incus \
--privileged \
--device /dev/kvm \
--device /dev/vsock \
--network host \
--volume /var/lib/incus:/var/lib/incus \
--volume /lib/modules:/lib/modules:ro \
incus-docker
```

NOTE: If you are using the alpine version, in most cases, you can't depend on the ability to load the modules for VMs automatically. You should set up your environment to automatically load vhost_vsock and kvm modules. You can do it like this:

```
echo "vhost_vsock" > /etc/modules-load.d/incus.conf
echo "kvm" >> /etc/modules-load.d/incus.conf
```


After you start the container, incus will be running. If you used the folder I suggested and used host networking, you can manage it immediately with the incus binary from the same machine. Grab the binary from the latest releases here:

https://github.com/lxc/incus/releases

For example, I use bin.linux.incus.x86_64 from the Assets at the above link.

You can then run **chmod +x bin.linux.incus.x86_64** to make it executable. Let's rename it to incus by running  **mv bin.linux.incus.x86_64 incus**

Now we can check it's working by running

```./incus admin init```

And we can proceed to configure incus.

I find it easiest to move the binary to /usr/local/bin so that I can just run **incus admin init** or whatever other incus command I need from PATH.

If you configure it to be manageable from the network, we can access the web UI, at https://{YOUR IP}:8443

I have tested on both arm64 and x86_64. Other platforms may work only if using the alpine image.

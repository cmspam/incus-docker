# incus-docker
A project to run incus in docker/podman

Incus is a fork of lxd. Please see here:
https://linuxcontainers.org/incus/

This project aims to maintain a Dockerfile to run incus in a docker/podman container.
It also installs the incus-ui-canonical to have a Web-based UI.

We now have a debian-based (Dockerfile) and an alpine-based (Dockerfile-alpine) option available.

We also have a smaller alpine-based version called alpine-novm which allows you to use contianers, but not virutal machines, to keep the image smaller.
Only the alpine-novm version is built for arm64 at present. It should be possible to build the other versions yourself on arm64, but I think VMs do not work anyway.

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

Although I have tested only on x86-64 as of yet, I believe it should work also with aarch64, though maybe not with vm support. I have tested btrfs support successfully, but have not implemented zfs support. A small modification of the dockerfile should allow it though.

# incus-docker
A project to run incus in docker/podman

Incus is a fork of lxd. Please see here:
https://linuxcontainers.org/incus/

This project aims to maintain a Dockerfile to run incus in a docker/podman container.
It also installs the incus-ui-canonical to have a Web-based UI.

We will eventually move to being alpine-based to keep the size smaller, but at the moment, due to issues with incus-agent on alpine, are basing on debian/bookworm.
We are using the version of incus maintained here:
https://github.com/zabbly/incus

How to use it:

Place the dockerfile somewhere, and run:

docker build -t cmspam/incus-docker .

Then, run the docker image. It will not work unless run as privileged. You will want to provide your own /var/lib/incus directory, and to allow it to automatically load the necessary modules when launching a VM (kvm and vsock_vhost) you may also want to give it your /lib/modules directory. Finally, because of incus's networking features, you will probably want to use host networking.  Therefore, you can do something like this on first run:

mkdir /var/lib/incus

docker run -d \
--name incus \
--privileged \
--restart unless-stopped \
--device /dev/kvm \
--device /dev/vsock \
--network host \
--volume /var/lib/incus:/var/lib/incus \
--volume /lib/modules:/lib/modules:ro \
cmspam/incus-docker


After you start the container, incus will be running. If you used the folder I suggested and used host networking, you can manage it immediately with the incus binary from the same machine. Grab the binary from the latest releases here:

https://github.com/lxc/incus/releases

For example, I use bin.linux.incus.x86_64 from the Assets at the above link.

You can then run chmod +x bin.linux.incus.x86_64 to make it executable. Let's rename it to incus by running mv bin.linux.incus.x86_64 incus
Now we can check it's working by running
./incus admin init
And we can proceed to configure incus.

I find it easiest to move the binary to /usr/local/bin so that I can just run "incus admin init" or whatever else.

If you configure it to be manageable from the network, we can access the web UI, at https://{YOUR IP}:8443

Although I have tested only on x86-64 as of yet, I believe it should work also with aarch64, though maybe not with vm support. I have tested btrfs support successfully, but have not implemented zfs support. A small modification of the dockerfile should allow it though.

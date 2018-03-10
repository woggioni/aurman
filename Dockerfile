# arch image with base-devel
FROM base/devel

# create user and set sudo priv
RUN useradd -m aurman -s /bin/bash
RUN echo 'aurman ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# switch user and workdir
USER aurman
WORKDIR /home/aurman

# multilib
RUN sudo sh -c "sed -i '/\[multilib\]/,/Include/s/^[ ]*#//' /etc/pacman.conf"

# makepkg
RUN sudo sh -c "sed -i '/MAKEFLAGS=/s/^.*$/MAKEFLAGS=\"-j\$(nproc)\"/' /etc/makepkg.conf"
RUN sudo sh -c "sed -i '/PKGEXT=/s/^.*$/PKGEXT=\".pkg.tar\"/' /etc/makepkg.conf"

# aurman requirements and sysupgrade
RUN sudo pacman --needed --noconfirm -Syu python expac python-requests pyalpm pacman sudo git python-regex

# add files of the current branch
ADD . /home/aurman/aurman-git

# chown, chmod and set entrypoint
RUN sudo chown -R aurman:aurman /home/aurman/aurman-git/src/docker_tests
RUN chmod +x -R /home/aurman/aurman-git/src/docker_tests
ENTRYPOINT for f in /home/aurman/aurman-git/src/docker_tests/*.sh; do /bin/bash $f; done

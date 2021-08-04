FROM vesoft/nebula-dev:latest

# WA: https://twitter.com/wey_gu/status/1422470992065036291?s=20
RUN touch /etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned

# rsync & ssh: https://www.jetbrains.com/help/clion/clion-toolchains-in-docker.html#build-and-run
RUN yum install -y rsync openssh-server

# rsync
RUN mkdir /root/sync

RUN printf "max connections = 8\n\
log file = /var/log/rsync.log\n\
timeout = 300\n\
[sync]\n\
comment = sync\n\
path = /root/sync\n\
read only = no\n\
list = yes\n\
uid = root\n\
gid = root\n"\
>> /etc/rsync.conf

# entrypoint with rsync & ssh
RUN printf "#!/bin/bash\n\
/usr/bin/rsync --daemon --config=/etc/rsync.conf\n\
/usr/sbin/sshd -D\n"\
>> /sbin/entrypoint.sh

RUN chmod +x /sbin/entrypoint.sh
CMD ["/sbin/entrypoint.sh"]

# ssh
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN echo 'root:password' |chpasswd
RUN echo 'UseDNS no' >> /etc/ssh/sshd_config

# env from nebula-dev
ENV PATH=/opt/vesoft/toolset/cmake/bin:/opt/vesoft/toolset/clang/9.0.0/bin:${PATH}
ENV CCACHE_CPP2=1
ENV CC=/opt/vesoft/toolset/clang/9.0.0/bin/gcc
ENV CXX=/opt/vesoft/toolset/clang/9.0.0/bin/g++
ENV GCOV=/opt/vesoft/toolset/clang/9.0.0/bin/gcov

# env for ssh access
RUN echo export PATH=/opt/vesoft/toolset/cmake/bin:/opt/vesoft/toolset/clang/9.0.0/bin:${PATH} >> /root/.bashrc
RUN echo CCACHE_CPP2=1 >> /root/.bashrc
RUN echo CC=/opt/vesoft/toolset/clang/9.0.0/bin/gcc >> /root/.bashrc
RUN echo CXX=/opt/vesoft/toolset/clang/9.0.0/bin/g++ >> /root/.bashrc
RUN echo GCOV=/opt/vesoft/toolset/clang/9.0.0/bin/gcov >> /root/.bashrc

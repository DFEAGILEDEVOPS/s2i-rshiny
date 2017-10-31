FROM openshift/base-centos7

MAINTAINER Simon Massey <massey1905@gmail.com>

# TODO consider loading version from a text file
ENV R_SHINY_SERVER_VERSION 1.5.3.838

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Shiny is an R package that makes it easy to build interactive web apps straight from R." \
      io.k8s.display-name="Shiny ${R_SHINY_SERVER_VERSION}" \
      io.openshift.expose-services="3838:http" \
      io.openshift.tags="builder,R,shiny,RShiny"

### Install shiny as per instructions at:
### https://www.rstudio.com/products/shiny/download-server/
RUN yum -y update && yum -y install epel-release wget && yum -y install R && yum clean all
RUN su - -c "R -e \"install.packages(c('shiny', 'rmarkdown', 'devtools', 'RJDBC', 'packrat'), repos='http://cran.rstudio.com/')\""
RUN wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-${R_SHINY_SERVER_VERSION}-rh5-x86_64.rpm && \
  yum -y install --nogpgcheck shiny-server-${R_SHINY_SERVER_VERSION}-rh5-x86_64.rpm && yum clean all

# Defines the location of the S2I
# Although this is defined in openshift/base-centos7 image it's repeated here
# to make it clear why the following COPY operation is happening
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i

# custom config which users user 'default' set by openshift
COPY etc/shiny-server.conf /etc/shiny-server/shiny-server.conf

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
RUN mkdir -p /var/lib/shiny-server/bookmarks && \
  chown default:0 /var/lib/shiny-server/bookmarks && \
  chmod g+wrX /var/lib/shiny-server/bookmarks && \
  mkdir -p /var/log/shiny-server && \
  chown default:0 /var/log/shiny-server && \
  chmod g+wrX /var/log/shiny-server 

## Also touch the packrat folder which is backed up and restored between incremental builds (use s2i with --incremental)
RUN id && echo " " && whoami && mkdir -p /opt/app-root/src/packrat/ && \
  chgrp -R 0 /opt/app-root/src/packrat/ && \
  chmod g+wrX /opt/app-root/src/packrat/

### Setup user for build execution and application runtime
### https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile.centos7
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

# openshift best practice is to use a number not a name this is user shiny
USER 1001

### Wrapper to allow user name resolution openshift will actually use a random user number so you need group permissions
### https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile.centos7
ENTRYPOINT [ "uid_entrypoint" ]
CMD run

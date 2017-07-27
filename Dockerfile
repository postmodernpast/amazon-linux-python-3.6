FROM amazonlinux:2017.03

# Make sure we're up-to-date
RUN yum update -y

# Install runtime requirements
RUN yum install -y binutils bzip2 gcc gcc-c++ gdbm libffi ncurses openssl \
  openssl readline sqlite xmlsec1 xmlsec1-openssl xz zlib zip

# Install build requirements
RUN yum install -y bzip2-devel gdbm-devel libffi-devel ncurses-devel \
  openssl-devel readline-devel sqlite-devel xz-devel zlib-devel

RUN mkdir /tmp/python-3.6-build
WORKDIR /tmp/python-3.6-build
RUN curl -o Python-3.6.2.tgz \
  https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz

RUN tar xfz Python-3.6.2.tgz
WORKDIR /tmp/python-3.6-build/Python-3.6.2
RUN ./configure --prefix=/usr --with-system-ffi --with-cxx-main=g++

# Make in parallel with 2x the number of processors.
RUN make -j $(( 2 * $(cat /proc/cpuinfo | egrep ^processor | wc -l) ))
RUN make install

WORKDIR /
RUN rm -rf /tmp/python-3.6-build

# Remove build-only requirements
RUN yum remove -y bzip2-devel gdbm-devel libffi-devel ncurses-devel \
  openssl-devel readline-devel sqlite-devel xz-devel zlib-devel zip-devel

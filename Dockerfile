#Pablo Alvarez EA1FID

FROM ubuntu:18.04

RUN apt-get update

# Set tztime
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y software-properties-common
#RUN add-apt-repository -y ppa:gnuradio/gnuradio-releases-3.8
RUN add-apt-repository -y ppa:gnuradio/gnuradio-releases
RUN apt-get update
RUN apt-get install -f
RUN apt-get install -y gnuradio
RUN apt-get install -f
RUN apt-get install -y gnuradio
RUN apt-get install -y python3-gi gobject-introspection gir1.2-gtk-3.0

# Necessary to share audio with x11docker
RUN apt-get install -y pulseaudio

ENTRYPOINT ["/usr/bin/gnuradio-companion"]


ENV HOME /root

# Install soapy

RUN add-apt-repository -y ppa:bladerf/bladerf
RUN add-apt-repository -y ppa:ettusresearch/uhd
RUN add-apt-repository -y ppa:gqrx/gqrx-sdr
RUN add-apt-repository -y ppa:myriadrf/drivers
RUN add-apt-repository -y ppa:myriadrf/gnuradio
RUN add-apt-repository -y ppa:pothosware/framework
RUN add-apt-repository -y ppa:pothosware/support
RUN apt-get update

RUN apt-get install -y soapysdr
RUN apt-get install -y python-soapysdr
RUN apt-get install -y python3-soapysdr

# Install all drivers

RUN apt-get install -y soapysdr-module-airspy soapysdr-module-redpitaya \
                        soapysdr-module-rfspace soapysdr-module-bladerf \
                        soapysdr-module-rtlsdr soapysdr-module-remote \
                        soapysdr-module-hackrf soapysdr-module-lms7 \
                        soapysdr-module-uhd soapysdr-module-mirisdr \
                        soapysdr-module-osmosdr

# Install gr-soapy

RUN apt-get install -y \
  libboost-dev \
  libboost-date-time-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-regex-dev \
  libboost-test-dev \
  python3 \
  python3-six \
  python3-mako \
  python3-dev \
  swig \
  cmake \
  gcc \
  gnuradio-dev \
  libsoapysdr-dev \
  libconfig++-dev \
  libgmp-dev \
  liborc-0.4-0 \
  liborc-0.4-dev \
  liborc-0.4-dev-bin \
  git

WORKDIR $HOME
RUN git clone https://gitlab.com/librespacefoundation/gr-soapy
WORKDIR gr-soapy
RUN git checkout v2.1.1
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j $(nproc --all)
RUN make install
RUN ldconfig

# Install gnuradio modules

RUN apt-get install -y python3-construct
RUN apt-get install -y python3-pip
RUN pip3 install --user --upgrade construct requests pybind11
WORKDIR $HOME
RUN git clone --recursive https://github.com/daniestevez/gr-satellites
WORKDIR gr-satellites
RUN git checkout maint-3.8
#RUN perl -i -p -e 's/Gnuradio "3.9"/Gnuradio "3.8"/g' CMakeLists.txt
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make
RUN make install
RUN ldconfig

RUN mkdir .gnuradio
WORKDIR .gnuradio
RUN echo "[audio_alsa]" > config.conf
RUN echo "nperiods = 32" > config.conf
RUN echo "period_time = 0.010" > config.conf
WORKDIR $HOME

# Doppler

#RUN git clone https://github.com/ghostop14/gr-gpredict-doppler.git
#WORKDIR gr-gpredict-doppler
#RUN git checkout maint-3.8
##RUN perl -i -p -e 's/Gnuradio "3.9"/Gnuradio "3.8"/g' CMakeLists.txt
#RUN mkdir build
#WORKDIR build
#RUN cmake ..
#RUN make -j $(nproc --all)
#RUN make install
#RUN ldconfig
#WORKDIR $HOME

RUN pip3 install chardet2

WORKDIR $HOME
RUN git clone git://github.com/urllib3/urllib3.git
WORKDIR urllib3
RUN git checkout 1.26.3
RUN python3 setup.py install

WORKDIR $HOME
RUN git clone git://github.com/certifi/python-certifi.git
WORKDIR python-certifi
RUN git checkout v1.0.1
RUN python3 setup.py install

WORKDIR $HOME
#RUN pip3 install chardet2 urllib3
RUN git clone https://github.com/psf/requests.git
WORKDIR requests
RUN git checkout  v2.25.1
RUN python3 setup.py install
WORKDIR $HOME


WORKDIR $HOME
#RUN python3.6 -m pip install requests chardet2 urllib3
RUN pip3 install orbit-predictor
RUN git clone https://github.com/acien101/gr-doppler.git
WORKDIR gr-doppler
#RUN git checkout 
RUN mkdir build
WORKDIR build
RUN cmake ../
RUN make -j4
RUN make install
RUN ldconfig

WORKDIR $HOME

# Pulseaudio dependency to run alongside x11docker

RUN apt-get install -y pulseaudio

ENV PYTHONPATH=/usr/local/lib/python3/dist-packages/

ENTRYPOINT ["/usr/bin/gnuradio-companion"]

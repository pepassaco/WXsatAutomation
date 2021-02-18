FROM acien101/gnuradio:3.8

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
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j $(nproc --all)
RUN make install
RUN ldconfig

# Install gnuradio modules

RUN apt-get install -y python3-pip
RUN pip3 install --user --upgrade construct requests
WORKDIR $HOME
RUN git clone --recursive https://github.com/daniestevez/gr-satellites
WORKDIR gr-satellites
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

RUN git clone https://github.com/ghostop14/gr-gpredict-doppler.git
WORKDIR gr-gpredict-doppler
RUN perl -i -p -e 's/Gnuradio "3.9"/Gnuradio "3.8"/g' CMakeLists.txt
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j $(nproc --all)
RUN make install
RUN ldconfig
WORKDIR $HOME

# Pulseaudio dependency to run alongside x11docker

RUN apt-get install -y pulseaudio

ENV PYTHONPATH=/usr/local/lib/python3/dist-packages/

ENTRYPOINT ["/usr/bin/gnuradio-companion"]

FROM ubuntu:focal

RUN apt update
RUN apt install -y software-properties-common dirmngr wget
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository --yes "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN add-apt-repository --yes ppa:c2d4u.team/c2d4u4.0+
RUN add-apt-repository --yes ppa:ubuntugis/ppa
RUN apt update -qq
RUN apt install -y r-base r-cran-shiny r-cran-plotly r-cran-tidyverse r-cran-leaflet r-cran-shinywidgets r-cran-dt r-cran-shinytest

RUN R --verion

RUN R -e "install.packages(c('thematic', 'bslib', 'shinytest2'), repos = c(CRAN = 'https://cloud.r-project.org'))"

RUN R -e "print('image built')"

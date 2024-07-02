# Use a base R image
FROM r-base:4.3.3

# Set the working directory
WORKDIR /app/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    aptitude \
    && aptitude install -y \
    bash \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    tzdata \
    gfortran \
    meson \
    pkg-config \
    ragel \
    gtk-doc-tools \
    gcc \
    g++ \
    libfreetype6-dev \
    libglib2.0-dev \
    libcairo2-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.47/quarto-1.5.47-linux-amd64.deb
RUN dpkg -i quarto-1.5.47-linux-amd64.deb
RUN rm quarto-1.5.47-linux-amd64.deb

# Set the PATH environment variable to include Quarto
ENV PATH="/opt/quarto/bin:${PATH}"

# Ensure pkg-config can find harfbuzz, freetype2, and fribidi
ENV PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/share/pkgconfig"

# Ensure pkg-config can find harfbuzz, freetype2, fontconfig, and fribidi
ENV PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/share/pkgconfig"

# Ensure R is installed and available
RUN which R || (echo "R not found, installing R." && apt-get update && apt-get install -y r-base)


# Install necessary packages
RUN R -e "install.packages('tidyverse', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('readxl', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('knitr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('kableExtra', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DT', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('quarto', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('here', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('harfbuzz', dependencies=TRUE, repos='http://cran.rstudio.com/')"


# Verify Rscript location
RUN which Rscript


# Copy your R script into the container
COPY behds/ /app/
RUN chmod +x /app/behds_terminal.R

# Command to run your R script
#CMD ["Rscript", "/app/behds_terminal.R"]

# Command to run your R script with arguments
ENTRYPOINT ["Rscript", "/app/behds_terminal.R"]


# Metadata labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="BEHDS" \
      org.label-schema.description="BEHDS - Behavioural to BIDS" \
      org.label-schema.url="https://behds.org" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/behds" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
FROM rocker/geospatial:4.4.2

# install rsconnect and renv packages, as well as prerequisite libraries
RUN apt-get update && apt-get install -y \
  libssl-dev make libcurl4-openssl-dev libxml2-dev cmake libicu-dev libx11-dev git libsodium-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libjpeg-dev libpng-dev libtiff-dev pandoc zlib1g-dev libglpk-dev
RUN install2.r rsconnect renv

# copy deploy script to root of the workspace
COPY deploy.R /deploy.R

# run deploy script, ignoring any .Rprofile files to avoid issues with conflicting
# library paths.
# TODO: this may cause issues if the .Rprofile does any setup required for the app to run
CMD ["Rscript", "--no-init-file", "/deploy.R"]

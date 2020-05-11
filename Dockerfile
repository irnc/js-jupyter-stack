# https://github.com/jupyter/docker-stacks/tree/master/base-notebook
FROM jupyter/base-notebook

COPY puppeteer-dependencies.txt .

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && cat puppeteer-dependencies.txt | xargs apt-get install -yq --no-install-recommends \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm puppeteer-dependencies.txt

USER $NB_USER

# Install latest LTS version of Node.js to use prebuilt zeromq (otherwise
# compiler should be installed during build).
#
# zeromq@5.2.0 is prebuilt for up to 72 ABI, which is Node.js 12.
RUN conda install --quiet --yes nodejs=12.16.1

# Install extensions to add Table of Contents to lengthy notebook.
# https://jupyter-contrib-nbextensions.readthedocs.io/en/latest/install.html
RUN conda install -c conda-forge jupyter_contrib_nbextensions
RUN jupyter contrib nbextension install --user

# Add RUN statements to install packages as the $NB_USER defined in the base images.
RUN npm install -g ijavascript && ijsinstall

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.

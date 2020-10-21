FROM databricksruntime/dbfsfuse:latest

ARG pip_config=pip.conf
ARG package_name=smartsegmentsml
ARG package_version=2.0.5

ENV PATH /databricks/conda/bin:$PATH

RUN apt-get update \
  && apt-get install --yes \
    # need these to compile hpfrec
    unixodbc \
    unixodbc-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && mkdir -p /root/.pip/

COPY "$pip_config" /root/.pip/pip.conf

RUN pip install "${package_name}"=="${package_version}" \
  && rm -r /root/.pip/

# Quick check
# docker container run --hostname $DOCKER_IMAGE_NAME --tty $DOCKER_IMAGE_NAME python -c "import smartsegmentsml.utils.load; print(smartsegmentsml.utils.load.version())"

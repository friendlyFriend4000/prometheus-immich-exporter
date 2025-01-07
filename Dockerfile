FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1

ENV IMMICH_API_TOKEN="yourimmichtokenhere"
ENV IMMICH_HOST="host/ip"
ENV IMMICH_PORT="2283"
#has to be EXPORT_PORT 8000 or else it does not work, same applies to the env file
ENV EXPORTER_PORT="8000"
ENV EXPORTER_LOG_LEVEL="INFO"

# Install package
WORKDIR /code
COPY . .

# arm64 needs gcc and python3-dev for `pip3 install`
# python version in python3-dev from bookworm is 3.11 (used same python verion in FROM)
# amd64 python image version has all dependencies installed already

ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        apt-get update  \
        && apt-get install -y --no-install-recommends gcc python3-dev  \
        && pip3 install --no-cache-dir .  \
        && apt-get remove -y --purge gcc python3-dev  \
        && apt-get autoremove -y  \
        && apt-get clean  \
        && rm -rf /var/lib/apt/lists/* ; \
else \
    pip3 install --no-cache-dir . ; \
fi

ENTRYPOINT [ "immich_exporter" ]

ARG CGO_ENABLED
ARG GO_VERSION
FROM golang:$GO_VERSION
LABEL maintainer="Mitchell Stanton <projects@mitchs.dev>"
ARG CGO_ENABLED
ENV CGO_ENABLED=$CGO_ENABLED
RUN useradd -ms /bin/bash -u 1000 app
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint
COPY scripts/generate-binary.sh /usr/local/bin/generate-binary
RUN mkdir -p /app
RUN chmod +x /usr/local/bin/entrypoint && \
chmod +x /usr/local/bin/generate-binary && \
chown -R app:app /app && \
chown -R app:app /usr/local/bin/entrypoint && \
chown -R app:app /usr/local/bin/generate-binary
WORKDIR /app
USER app
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
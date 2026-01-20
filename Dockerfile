FROM node:24-slim

# base runtime deps
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl tar \
  && rm -rf /var/lib/apt/lists/*

# create runtime user
RUN useradd -m -d /home/cursor -s /bin/bash cursor

# install cursor agent
RUN curl -fsS https://cursor.com/install | bash \
  && mkdir -p /usr/local/share/cursor-agent \
  && cp -R /root/.local/share/cursor-agent/* /usr/local/share/cursor-agent/ \
  && ln -s /usr/local/share/cursor-agent/versions/*/cursor-agent /usr/local/bin/agent

# install docker cli + compose plugin
RUN arch="$(uname -m)" \
  && case "$arch" in \
    x86_64) docker_arch="x86_64"; compose_arch="x86_64" ;; \
    aarch64|arm64) docker_arch="aarch64"; compose_arch="aarch64" ;; \
    *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://download.docker.com/linux/static/stable/${docker_arch}/docker-27.4.1.tgz" \
    | tar xz -C /tmp \
  && mv /tmp/docker/docker /usr/local/bin/docker \
  && rm -rf /tmp/docker \
  && chmod +x /usr/local/bin/docker \
  && mkdir -p /usr/local/lib/docker/cli-plugins \
  && curl -fsSL "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-${compose_arch}" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose \
  && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

USER cursor

ENV DOCKER_HOST=tcp://docker-proxy:2375
ENV HOME=/home/cursor
ENV TERM=xterm-256color
WORKDIR /home/cursor

COPY . .

# pre-create the workspace trusted file for /home/cursor
# this does prevent the agent from prompting for the workspace trust,
# but it causes the agent to hang.
# RUN workspace_path="/home/cursor" \
#   && slug="$(printf '%s' "$workspace_path" \
#     | sed -E 's/[^a-zA-Z0-9]/-/g; s/-+/-/g; s/^-+//; s/-+$//')" \
#   && project_dir="/home/cursor/.cursor/projects/${slug}" \
#   && mkdir -p "$project_dir" \
#   && echo "{\"trustedAt\":\"$(date '+%Y-%m-%dT%T.000Z')\",\"workspacePath\":\"${workspace_path}\"}" \
#     > "${project_dir}/.workspace-trusted"

ENTRYPOINT ["/home/cursor/agent-entrypoint.sh"]

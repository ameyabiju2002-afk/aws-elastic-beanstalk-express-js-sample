# Node 16 + Docker CLI preinstalled
FROM node:16

# Avoid interactive prompts; install only the docker client quickly
RUN apt-get update \
 && apt-get install -y --no-install-recommends docker.io ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Clear entrypoint so Jenkins can run arbitrary commands without warnings
ENTRYPOINT [""]

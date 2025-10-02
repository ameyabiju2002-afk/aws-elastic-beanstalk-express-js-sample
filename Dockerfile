# Node 16 on Alpine (repos still live)
FROM node:16-alpine

# Install Docker CLI on Alpine
RUN apk add --no-cache docker-cli ca-certificates

# Let Jenkins run commands without entrypoint noise
ENTRYPOINT [""]

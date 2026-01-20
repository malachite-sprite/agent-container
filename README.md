# Agent Container
Agent Container is a docker-based sandbox environment for safely running AI coding agents in "yolo mode" without sacrificing utility.

## Use
First build the docker image
    
    docker compose build

Then start the agent container

    docker compose run --rm -it agent-container

## Docker access
Agent Container uses a docker socket proxy to expose limited, read-only access to docker containers running on the host machine. The proxy is configured with an explicit allowlist of API areas (currently containers and logs only).

## Network access
The agent has full network access. Although this has some risks, the risks a low if the agent doesn't have any credentials to access remote systems.

## Credential access
The agent does not use `env_file` for secrets. Instead, it reads the Cursor API key from a Docker secret at `/run/secrets/cursor_api_key` and passes it directly to the agent process. The secret file is expected at `secrets/.cursor_api_key` (not committed).

## Filesystem access
The container root filesystem is read-only. The only writable bind mount is `/home/cursor/projects`, which maps to `~/Code` on the host. Runtime writable paths are provided via tmpfs mounts.

## Resource limits
The agent container uses resource limits to reduce impact from runaway processes (CPU, memory, pids, and file descriptors).

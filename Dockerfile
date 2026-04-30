FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Add the NEW GPG key (Required for Trixie/Ubuntu 24.04+)
RUN gpg --keyserver keyserver.ubuntu.com --recv D43AD4708A2DA1139F250B3294E40E5320D8AE3C \
    && gpg --export D43AD4708A2DA1139F250B3294E40E5320D8AE3C > /etc/apt/trusted.gpg.d/aprsc.key.gpg

# 3. Add the repository using the 'trixie' codename
RUN echo "deb http://aprsc-dist.he.fi/aprsc/apt trixie main" > /etc/apt/sources.list.d/aprsc.list

# 4. Install aprsc
RUN apt-get update && apt-get install -y \
    aprsc \
    && rm -rf /var/lib/apt/lists/*

# 5. Setup directories and permissions
RUN mkdir -p /opt/aprsc/logs && chown -R aprsc:aprsc /opt/aprsc

# Expose ports: 14580 (Client)
EXPOSE 14580

# Run as the aprsc user for security
USER aprsc

# Start in foreground (-f) and log to stderr (-e info) so Docker can capture logs
ENTRYPOINT ["/opt/aprsc/sbin/aprsc"]
CMD ["-f", "-e", "info", "-c", "/opt/aprsc/etc/aprsc.conf"]

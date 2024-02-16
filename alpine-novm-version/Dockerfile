# Stage 1 to build the UI
FROM alpine:edge AS ui

# Set the working directory
WORKDIR /build/incus-ui-canonical

# Install git and other necessary tools
RUN apk add --no-cache git rsync

# Add the Alpine/Edge testing repository
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Clone the LXD-UI repository
RUN git clone https://github.com/canonical/lxd-ui.git /build/incus-ui-canonical

# Apply specific tweaks
RUN sed -i "s/LXD/Incus/g" src/*/*.ts* src/*/*/*.ts* src/*/*/*/*.ts* \
    && sed -i "s/devlxd/guestapi/g" src/*/*.ts* src/*/*/*.ts* src/*/*/*/*.ts* \
    && sed -i "s/dev\/lxd/dev\/incus/g" src/*/*.ts* src/*/*/*.ts* src/*/*/*/*.ts* \
    && sed -i "s/lxd_/incus_/g" src/*/*.ts* src/*/*/*.ts* src/*/*/*/*.ts* \
    && sed -i "s/\"lxd\"/\"incus\"/g" src/*/*.ts* src/*/*/*.ts* src/*/*/*/*.ts*

# Build the UI
RUN apk add --no-cache nodejs npm \
    && npm install yarn --global \
    && yarn install \
    && yarn build

# Create the target directory for UI files
RUN mkdir -p /opt/incus/ui-canonical/

# Copy the built UI files to the target directory
RUN rsync -a /build/incus-ui-canonical/build/ui/ /opt/incus/ui-canonical/

#Stage 2: Create the container
FROM alpine:edge
COPY --from=ui /opt/incus/ui-canonical /opt/incus/ui-canonical

# Install the required packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
    incus \
    incus-client \
    btrfs-progs \
    iptables-legacy \
    zfs && \
    echo '#!/bin/sh' > /start.sh && \
    echo 'export INCUS_UI="/opt/incus/ui-canonical/"' >> /start.sh && \
    echo 'if [ "$SETIPTABLES" = "true" ]; then' >> /start.sh && \
    echo 'if ! iptables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'iptables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'if ! ip6tables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo 'ip6tables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'incusd' >> /start.sh && \
    chmod +x /start.sh


# Start the service
CMD /start.sh

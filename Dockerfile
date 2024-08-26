# Use the multi-architecture supported bitcoind image as the base
FROM lukechilds/bitcoind:latest AS build

# Install dependencies for ckpool and runtime libraries
RUN apt-get update && apt-get install -y \
    build-essential yasm autoconf automake libtool libzmq3-dev pkgconf git

# Clone and build ckpool from Bitbucket
RUN git clone https://bitbucket.org/ckolivas/ckpool-solo.git /opt/ckpool && \
    cd /opt/ckpool && \
    ./autogen.sh && \
    ./configure && \
    make

# Verify that the ckpool binary exists and copy it to a standard location
RUN ls /opt/ckpool/src/ckpool && cp /opt/ckpool/src/ckpool /opt/ckpool/ || echo "ckpool build failed or binary not found"

# Use the same base image for the final container
FROM lukechilds/bitcoind:latest

# Install libzmq in the runtime container
RUN apt-get update && apt-get install -y libzmq5

# Copy ckpool binary and dependencies from the build stage
COPY --from=build /opt/ckpool /opt/ckpool

# Copy the ckpool config file
COPY ./ckpool.conf /opt/ckpool/conf/ckpool.conf

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Declare a volume for the blockchain data
VOLUME ["/bitcoin/.bitcoin"]

# Expose necessary ports
EXPOSE 8333 18332 18333 28332

# Use the script as the entrypoint
ENTRYPOINT ["/entrypoint.sh"]


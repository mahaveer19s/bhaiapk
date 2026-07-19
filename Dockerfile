FROM alpine:3.18

ARG PB_VERSION=0.22.14

RUN apk add --no-cache \
    unzip \
    ca-certificates \
    curl

# Download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/ && rm /tmp/pb.zip

# Create volume directories
RUN mkdir -p /pb/pb_data /pb/pb_public /pb/pb_migrations

# Expose server port
EXPOSE 8080

# Start PocketBase and serve
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]

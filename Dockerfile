# Dockerfile for FloImg Fleet
# Multi-stage build optimized for Coolify deployment
# Based on GoFlojo pattern

# Build arguments for version pinning
ARG ELIXIR_VERSION=1.18.4
ARG OTP_VERSION=28.3
ARG DEBIAN_VERSION=bookworm-20251208-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM ${BUILDER_IMAGE} AS builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set build environment
ENV MIX_ENV=prod

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files first (for layer caching)
COPY mix.exs mix.lock ./

# Fetch dependencies
RUN mix deps.get --only $MIX_ENV

# Copy compile-time config files
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/

# Compile dependencies
RUN mix deps.compile

# Copy application source
COPY lib lib
COPY priv priv
COPY assets assets

# Compile assets (Tailwind + esbuild via Mix tasks)
RUN mix assets.deploy

# Compile application
COPY config/runtime.exs config/
RUN mix compile

# Copy release configuration
COPY rel rel

# Build release
RUN mix release

# =============================================================================
# Stage 2: Runtime
# =============================================================================
FROM ${RUNNER_IMAGE} AS runner

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses5 \
    locales \
    ca-certificates \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale for Elixir
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

# Create non-root user for security
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --home /app appuser && \
    chown -R appuser:appgroup /app

# Copy release from builder
COPY --from=builder --chown=appuser:appgroup /app/_build/prod/rel/floimg_fleet ./

# Ensure release scripts are executable
RUN chmod +x /app/bin/*

# Switch to non-root user
USER appuser

# Expose Phoenix port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:4000/health || exit 1

# Start the application
CMD ["/app/bin/server"]

# === Stage 1: Build ===
FROM elixir:1.18.4-alpine AS build

WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

COPY config/ /app/config/
COPY mix.exs /app/
COPY mix.* /app/

COPY apps/payments/mix.exs /app/apps/payments/
COPY apps/people/mix.exs /app/apps/people/
COPY apps/memberships/mix.exs /app/apps/memberships/
COPY apps/pub_sub/mix.exs /app/apps/pub_sub/
COPY apps/shared_kernel/mix.exs /app/apps/shared_kernel/

ENV MIX_ENV=dev
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . /app/

WORKDIR /app
RUN MIX_ENV=dev mix release

# === Stage 2: Runtime ===
FROM alpine:3.19 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

ENV MIX_ENV=dev \
	LANG=en_US.UTF-8 \
	REPLACE_OS_VARS=true \
	HOME=/app

WORKDIR /app

COPY --from=build /app/_build/$MIX_ENV/rel/helix_club ./

EXPOSE 4000
EXPOSE 4001
EXPOSE 4002

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

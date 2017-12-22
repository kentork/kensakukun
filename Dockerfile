FROM elixir:1.5.3-alpine
RUN mix local.hex --force && mix local.rebar --force

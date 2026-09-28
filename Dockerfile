FROM elixir:1.17.3-otp-26-alpine

RUN apk add --no-cache build-base npm git inotify-tools netcat-openbsd

WORKDIR /TimeManager

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get

COPY . .

RUN chmod +x entrypoint.sh

EXPOSE 4000

ENTRYPOINT [ "/TimeManager/entrypoint.sh" ]


FROM elixir:1.7.4

RUN mix local.hex --force
RUN mix archive.install --force hex phx_new 1.4.0
RUN mix local.rebar --force

WORKDIR /app
COPY . .

EXPOSE 4000

# Initial setup
RUN mix deps.get
# RUN mix deps.get --only prod
# RUN MIX_ENV=prod mix compile

# Install NodeJS 8.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y -q nodejs
RUN cd assets && npm install
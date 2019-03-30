# The Arrows game
Elixir/Phoenix based game.

## Getting started

  * `docker-compose run --rm web mix deps.get`
  * `docker-compose run --rm web mix ecto.migrate`
  * `docker-compose run --rm web bash -c "cd assets && npm install"`
  * `docker-compose up -d`

Now you can visit [`localhost`](http://localhost) from your browser.

## AI
- `docker-compose run --rm ai python train.py` trains AI and saves network weights to `weights.hdf5`

## Deploy 
- `./bin/deploy.sh`

## TODO
* adds
* list games
* bot
* create logo
* championships
* delete guest users
* no "Draw" if someone exits
* tutorial
* real time lag, ping to server
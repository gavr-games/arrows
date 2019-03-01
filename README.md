# The Arrows game
Elixir/Phoenix based game.

## Getting started

  * `docker-compose run web mix deps.get`
  * `docker-compose run web mix ecto.migrate`
  * `docker-compose run web bash -c "cd assets && npm install"`
  * `docker-compose up -d`

Now you can visit [`localhost`](http://localhost) from your browser.

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
* delete games with no actions taken
* tutorial
* real time lag, ping to server
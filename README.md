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
* countdown before game starts
* merge balls
* dynamic window height (mobile)
* adds
* list games
* bot
* create logo
* championships
* delete guest users
* add jump ball ability (cooldown per ball)

# The Arrows game
Elixir/Phoenix based game.

## Getting started

  * `docker-compose run web mix deps.get`
  * `docker-compose run web mix ecto.migrate`
  * `docker-compose run web bash -c "cd assets && npm install"`
  * `docker-compose up -d`

Now you can visit [`localhost`](http://localhost) from your browser.

## Deploy 
Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## TODO
* countdown before game starts
* merge balls
* dynamic window height (mobile)
* adds
* list games
* deploy
* bot

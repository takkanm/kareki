# kareki

[![Heroku Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/takkanm/kareki)

## What's this application

## Deploy to Heroku

You can deploy to Heroku use heroku buttion on README.
You should set some Enviroment Variables, and create.
If deploy Heroku, you should set Heroku Scheduler.

```
# if you send idobata
bundle exec rails runner 'Feed.crawl_and_push(Subscriber::Idobata)'
```

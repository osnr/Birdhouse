Birdhouse is a library/framework for writing Twitter bots in Elm.

You need at least Elm 0.11 to compile, as well as a Twitter account and developer API key for your bot.

You'll want to compile an example. Right now, we only have examples/EveryMNLake, so create a Keys.elm file with your API keys, then run `make` in EveryMNLake. Host an HTTP server out of examples/EveryMNLake/build and visit index.html to authorize and start your bot.

Birdhouse uses [codebird-js](https://github.com/jublonet/codebird-js) to get past the cross-origin restriction, so it runs your Twitter API calls through Jublo's proxy by default.

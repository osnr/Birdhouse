Birdhouse is a library/framework for writing Twitter bots in Elm.

You need at least Elm 0.11 to compile, as well as a Twitter account, developer API key, and access token for your bot. Make sure you link or copy your elm-runtime.js into `lib/` here.

You'll want to compile an example (the library can't compile standalone). Counter is the simplest. Go to `examples/Counter/`. Create Keys.elm (see Keys.elm.example) with your API keys from the Twitter developer settings. Run `make`, then `cd build`, then run an HTTP server and visit /index.html on the server. The bot should start automatically.

Birdhouse uses [codebird-js](https://github.com/jublonet/codebird-js) to get past the cross-origin restriction, so it runs your Twitter API calls through Jublo's proxy by default.

Running bots:
- [@EveryMNLake](https://twitter.com/EveryMNLake)

(function() {
    var cb;
    try {
        var keys = Elm.worker(Elm.Keys);

        cb = new Codebird;
        cb.setConsumerKey(keys.ports.apiKey, keys.ports.apiSecret);
        cb.setToken(keys.ports.accessToken, keys.ports.accessTokenSecret);
    } catch (e) {
        console.log("Keys failed. Running Bot without Twitter connection", e);
    }

    var bot;
    try {
        bot = Elm.embed(Elm.Bot, document.getElementById("elm-surface"),
                        { tweets: null });
    } catch (e) {
        console.log("Embed failed. Running Bot as worker");
        bot = Elm.worker(Elm.Bot,
                        { tweets: null });
    }

    bot.ports.updates.subscribe(function(update) {
        if (!update || !cb) return;

        update["display_coordinates"] = String(update["display_coordinates"]);

        cb.__call(
            "statuses_update",
            update,
            function(reply) {
                console.log("response to statuses_update", update, reply);
            }
        );
    });

    if (!bot.ports.getTweetsFrom) return;
    bot.ports.getTweetsFrom.subscribe(function(screenNames) {
        for (var i = 0; i < screenNames.length; i++) {
            cb.__call(
                "statuses_userTimeline",
                { screen_name: screenNames[i] },
                function(reply) {
                    console.log(reply[0]);
                    bot.ports.tweets.send([String(screenNames[i]), reply[0]]);
                }
            );
        }
    });
})();

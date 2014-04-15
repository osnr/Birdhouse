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
        bot = Elm.embed(Elm.Bot, document.getElementById("elm-surface"));
    } catch (e) {
        console.log("Embed failed. Running Bot as worker");
        bot = Elm.worker(Elm.Bot);
    }

    bot.ports.updates.subscribe(function(update) {
        if (!update || !cb) return;

        delete update["_"];

        update["long"] = update["lon"];
        delete update["lon"];

        update["display_coordinates"] = String(update["display_coordinates"]);

        cb.__call(
            "statuses_update",
            update,
            function(reply) {
                console.log("response to statuses_update", update, reply);
            }
        );
    });
})();

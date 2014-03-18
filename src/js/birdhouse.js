(function() {
    var keys = Elm.worker(Elm.Keys);

    var cb = new Codebird;
    cb.setConsumerKey(keys.ports.apiKey, keys.ports.apiSecret);
    cb.setToken(keys.ports.accessToken, keys.ports.accessTokenSecret);

    var bot = Elm.embed(Elm.Bot, document.getElementById("elm-surface"));
    bot.ports.updates.subscribe(function(update) {
        if (!update) return;

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

var cb;
window.onload = function() {
    document.body.innerHTML += '\
        <div id="authorize">\
            <p><button id="start-authorize">Authorize bot for your Twitter account</button></p>\
            <p id="pin-step" style="display: none">\
                <input id="pin" type="text" placeholder="PIN from Twitter"></input>\
                <button id="finish">Finish authorization</button>\
            </p>\
        </div>\
        <div id="authorized" style="display: none">Authorized. Bot is running.</div>\
        <div id="elm-surface"></div>\
    ';

    var keys = Elm.worker(Elm.Keys);

    cb = new Codebird;
    cb.setConsumerKey(keys.ports.apiKey, keys.ports.apiSecret);

    var oauth_token = localStorage["oauth_token"],
        oauth_token_secret = localStorage["oauth_token_secret"];
    if (oauth_token && oauth_token_secret) {
        ready(oauth_token, oauth_token_secret);
    } else {
        prepAuthorize();
    }
};

var prepAuthorize = function() {
    // gets a request token
    cb.__call(
        "oauth_requestToken",
        {oauth_callback: "oob"},
        function (reply) {
            // stores it
            cb.setToken(reply.oauth_token, reply.oauth_token_secret);

            // gets the authorize screen URL
            cb.__call(
                "oauth_authorize",
                {},
                function (auth_url) {
                    document.getElementById("start-authorize").onclick = startAuthorize(auth_url);
                }
            );
        }
    );

    var startAuthorize = function(auth_url) {
        return function() {
            window.open(auth_url);
            document.getElementById("pin-step").style.display = "";
            document.getElementById("finish").onclick = finishAuthorize;
        };
    };

    var finishAuthorize = function() {
        var pin = document.getElementById("pin").value;

        cb.__call(
            "oauth_accessToken",
            {oauth_verifier: pin},
            function (reply) {
                localStorage["oauth_token"] = reply.oauth_token;
                localStorage["oauth_token_secret"] = reply.oauth_token_secret;

                ready(reply.oauth_token, reply.oauth_token_secret);
            }
        );
    };
};

var ready = function(oauth_token, oauth_token_secret) {
    cb.setToken(oauth_token, oauth_token_secret);

    document.getElementById("authorize").style.display = "none";
    document.getElementById("authorized").style.display = "";

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
};

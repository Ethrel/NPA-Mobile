window.setTimeout(
    function () {
        NeptunesPride.np.on("order:full_universe", function () {
            Mousetrap.trigger("(");
        });
        Mousetrap.trigger("(");
    }
    , 1000);
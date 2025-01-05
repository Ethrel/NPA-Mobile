window.setTimeout(
    function () {
        NP.np.listen(window.NeptunesPride.crux,"order:full_universe",function() {
            Mousetrap.trigger("(");
        });
        Mousetrap.trigger("(");
    }
    , 1000);

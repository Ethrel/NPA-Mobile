window.setTimeout(
    function () {
        NP.np.listen(window.NeptunesPride.crux,"order:full_universe",function() {
            Mousetrap.trigger("(");
        });
        Mousetrap.trigger("(");
    }
    , 1000);

// TODO: This solves the zoom issue (kinda). Still is too zommed on load for the top bar and such. Need to figure that out.
//<meta name="viewport" content="width=device-width, initial-scale=1">
var flutterViewPort=document.createElement('meta');
flutterViewPort.name = "viewport";
flutterViewPort.content = "width=device-width, initial-scale=0.75";
document.getElementsByTagName('head')[0].appendChild(flutterViewPort);
        
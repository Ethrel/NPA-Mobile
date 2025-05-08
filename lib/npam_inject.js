NeptunesPride.NPAM = {
    listHotkeys: function listHotkeys() {
        const ret = [];
        for (let modifier of ['shift+', 'ctrl+', '']) {
            for (let key of '`1234567890-=~!@#$%^&*()_+qwertyuiop[]\asdfghjkl;zxcvbnm,./{}|:"<>?\'') {
                const span = Crux.format(`[[goto:${modifier}${key}]]`, {}).replaceAll('">"', '"&gt;"');
                const label = span.split(/[<>]/)[2];
                if (label && span.indexOf('Trigger goto') === -1) {
                    //console.log(`Hotkey ${modifier}${key} is ${label}`);
                    //ret.push({ modifier, key, description: label, });
                    this.send({ modifier, key, label }, "hotkey");
                }
            }
        }
    },
    send(data, type = null) {
        if (typeof (data) == "string") {
            type ??= "string";
            NPAMChannel.postMessage(JSON.stringify({ type: type, data: data }));
        } else {
            type ??= "json";
            NPAMChannel.postMessage(JSON.stringify({ type: type, data: JSON.stringify(data) }));
        }
    }
}

window.setTimeout(
    function () {
        NP.np.listen(window.NeptunesPride.crux,"order:full_universe",function() {
            Mousetrap.trigger("(");
        });
        Mousetrap.trigger("(");
    }
    , 1000);

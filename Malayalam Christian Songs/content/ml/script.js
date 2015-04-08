function resizeText(multiplier) {
    if (document.body.style.fontSize == "") {
        document.body.style.fontSize = "1.0em";
    }
    var fontSize = parseFloat(document.body.style.fontSize) + (multiplier * 0.2) + "em";
    document.body.style.fontSize = fontSize;
    window.localStorage["fontSize"] = fontSize;
}
function init() {
    var fontSize = window.localStorage["fontSize"];
    if(fontSize) {
        document.body.style.fontSize = fontSize;
    }
}
window.onload = function() {
    init();
}
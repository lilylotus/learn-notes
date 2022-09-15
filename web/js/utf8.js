function ConvUtf(obj, btn) {
    document.getElementById("result").value = obj.value.replace(/[^\u0000-\u00FF]/g, function ($0) { return escape($0).replace(/(%u)(\w { 4 })/gi, "&#x$2; ") });
}
function ResChinese(obj, btn) {
    document.getElementById("result").value = unescape(obj.value.replace(/&#x/g, '%u').replace(/; /g, ''));
}
function Empty() {
    document.getElementById("contents").value = "";
    document.getElementById("result").value = "";
    document.getElementById("contents").select();
}
$('head').append(
    '<style type="text/css">#container { display: none; } #fade, #loader { display: block; }</style>'
);
 
function fade() {
    var pageH = $("#container").height();
 
    $("#fade").css("height", pageH).delay(900).fadeOut(800);
    $("#loader").delay(600).fadeOut(300);
    $("#container").css("display", "block");
}

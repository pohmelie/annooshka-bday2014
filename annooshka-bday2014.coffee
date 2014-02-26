$(() ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20
    ctx.canvas.width = w
    ctx.canvas.height = h

    ctx.lineWidth = 2
    ctx.strokeStyle = "#ffffff"

    ctx.moveTo(0, 0)
    ctx.lineTo(w, h)

    ctx.stroke()

)

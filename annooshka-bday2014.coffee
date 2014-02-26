$(() ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20

    ctx.canvas.width = w
    ctx.canvas.height = h

    ctx.fillStyle = "#00F"
    ctx.strokeStyle = "#F00"
    ctx.font = "30pt Arial"
    ctx.fillText("#{w}x#{h} #{window.devicePixelRatio}", 0, 100)

    ctx.lineWidth = 2
    ctx.strokeStyle = "#ffffff"

    ctx.moveTo(0, 0)
    ctx.lineTo(w, h)

    ctx.stroke()

)

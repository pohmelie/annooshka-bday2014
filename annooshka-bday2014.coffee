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


    ctx.beginPath()
    ctx.moveTo(305, 300)
    ctx.bezierCurveTo(200, 175, 400, 175, 295, 300)
    ctx.lineTo(295, 300)
    ctx.closePath()

    ctx.lineWidth = 1
    ctx.fillStyle = "rgba(0, 0, 255, 0.5)"
    ctx.fill()
    ctx.strokeStyle = "#000"
    ctx.stroke()

)
###

$(() ->

    background = "#293134"
    $("body").css("background", background)

    width = $(window).width() - 20
    height = $(window).height() - 20

    ctx = $("#area")[0].getContext("2d")
    ctx.canvas.width = width
    ctx.canvas.height = height

    per_degree = Math.PI / 180
    wx = 40 * per_degree
    wy = 40 * per_degree
    wz = 0

    time = 0
    delta = 25

    scale = 1
    z_infulece = 0.001

    points = [
        [
            [-100, 100, 100],
            [100, 100, 100],
            [100, -100, 100],
            [-100, -100, 100],
            [-100, 100, 100],
            [-100, 100, -100],
            [-100, -100, -100],
            [100, -100, -100],
            [100, 100, -100],
            [-100, 100, -100],
        ],
        [
            [-100, -100, 100],
            [-100, -100, -100],
        ],
        [
            [100, -100, 100],
            [100, -100, -100],
        ],
        [
            [100, 100, 100],
            [100, 100, -100],
        ],

    ]


    rotate = (x, y, z, alpha, betta, gamma) ->

        [sa, ca] = [Math.sin(alpha), Math.cos(alpha)]
        [sb, cb] = [Math.sin(betta), Math.cos(betta)]
        [sg, cg] = [Math.sin(gamma), Math.cos(gamma)]

        return [
            x * (cb * cg) + y * (-cb * sg) + z * sb,
            x * (sa * sb * cg + ca * sg) + y * (-sa * sb * sg + ca * cg) + z * (-sa * cb),
            x * (-ca * sb * cg + sa * sg) + y * (ca * sb * sg + sa * cg) + z * (ca * cb)
        ]


    iteration = () =>

        ctx.fillStyle = background
        ctx.fillRect(0, 0, width, height)

        for path in points

            init_point = false

            for [x, y, z] in path

                [rx, ry, rz] = rotate(x, y, z, wx * time, wy * time, wz * time)

                sx = (1 + rz * z_infulece) / scale * rx + width / 2
                sy = (1 + rz * z_infulece) / scale * ry + height / 2

                if init_point

                    ctx.beginPath()
                    [mx, my] = init_point
                    ctx.moveTo(mx, my)
                    ctx.lineTo(sx, sy)
                    cc = 1.0 + (rz + prev_z) / 300

                    ctx.lineWidth = 3 * cc
                    ctx.strokeStyle = "rgba(#{103 * cc}, #{140 * cc}, #{177 * cc}, 1.0)"
                    ctx.stroke()

                prev_z = rz
                init_point = [sx, sy]

                ctx.beginPath()
                ctx.arc(sx, sy, 3, 0, 2 * Math.PI)
                ctx.fillStyle = "#ffcd22"
                ctx.fill()

        time = time + delta / 1000
        setTimeout(iteration, delta)


    iteration()

)
###

#= require <blocks.coffee>


draw_ellipse_by_center = (ctx, cx, cy, w, h) ->

    draw_ellipse(ctx, cx - w/2.0, cy - h/2.0, w, h)

draw_ellipse = (ctx, x, y, w, h) ->

    kappa = .5522848
    ox = (w / 2) * kappa  # control point offset horizontal
    oy = (h / 2) * kappa  # control point offset vertical
    xe = x + w            # x-end
    ye = y + h            # y-end
    xm = x + w / 2        # x-middle
    ym = y + h / 2        # y-middle

    ctx.moveTo(x, ym)
    ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
    ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
    ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
    ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)


class Background

    constructor: (@color) ->

    redraw: (ctx) ->

        ctx.fillStyle = @color
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)


class Platform

    constructor: (@x, @y, @width, @height, @delta) ->

    step_left: () ->

        @x = Math.max(0, @x - @delta)

    step_right: () ->

        @x = Math.min(ctx.canvas.width - @width, @delta)

    redraw: (ctx) ->

        ctx.fillStyle = "#fff"
        ctx.fillRect(@x, @y, @width, @height)


class Block

    constructor: (@x, @y, @radius, @type) ->

    shot: () ->

        @type = Math.max(-1, @type - 1)

    redraw: (ctx) ->

        switch @type

            when 1

                ctx.fillStyle = "#f00"

            when 0

                ctx.fillStyle = "#0f0"

            when -1

                return

        ctx.beginPath()
        ctx.arc(@x, @y, @radius, 0, 2 * Math.PI, false)
        # draw_ellipse_by_center(ctx, @x, @y, @width, @height)
        ctx.closePath()
        ctx.fill()

    @build_blocks_from_map: (map, sx, sy, radius) ->

        blocks = []
        iy = 0.5
        for line in map

            ix = 0.5
            blocks_line = []
            for ch in line

                switch ch

                    when "."

                        n = 0

                    when "#"

                        n = 1

                blocks.push(
                    new Block(
                        sx + ix * radius * 2,
                        sy + iy * radius * 2,
                        radius,
                        n
                    )
                )
                ix += 1

            iy += 1

        return blocks


class Ball

    constructor: (@x, @y, @dx, @dy, @radius) ->

    redraw: (ctx) ->

        ctx.beginPath()
        ctx.arc(@x, @y, @radius, 0, 2 * Math.PI, false)
        ctx.closePath()
        ctx.fillStyle = "#00f"
        ctx.fill()


class Game

    constructor: (@ctx, @static_objects, @platform, @ball, @w, @h, @interval=30) ->

        setInterval(@iteration, @interval)

    iteration: () =>

        @static_objects.forEach((e) => e.redraw(@ctx))
        @ball.redraw(@ctx)
        @platform.redraw(@ctx)
        @ball.redraw(@ctx)


resize_blocks = (blocks_map, w, h) ->

    lines = blocks_map.split("\n")
    blk_diameter_w = w / lines[0].length
    blk_diameter_h = h / lines.length / 2
    if blk_diameter_w > blk_diameter_h

        ncount = w / blk_diameter_h
        dcount = ncount - lines[0].length
        extra = ""
        for _ in [0...Math.floor(dcount / 2)]

            extra += "."

        for i in [0...lines.length]

            lines[i] = extra + lines[i] + extra

        return [lines, blk_diameter_h / 2]

    else

        return [lines, blk_diameter_w / 2]


$(() ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20

    ctx.canvas.width = w
    ctx.canvas.height = h

    static_objects = [new Background("#293134")]
    [blocks, radius] = resize_blocks(blocks_map, w, h)
    static_objects = static_objects.concat(Block.build_blocks_from_map(blocks, 0, 0, radius))

    g = new Game(
        ctx,
        static_objects,
        new Platform(w * 0.9 / 2, h * 0.975 - 5, w * 0.1, h * 0.025, 5),
        new Ball(w / 2, h * 0.8, 1, -1, 10),
        w,
        h
    )

)

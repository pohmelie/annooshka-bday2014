#= require <blocks.coffee>


class Background

    constructor: (@color) ->


    redraw: (ctx) ->

        ctx.fillStyle = @color
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)


class Platform

    constructor: (@x, @y, @width, @radius, @sa, @ea, @delta) ->

        $(window).on("keydown", @keydown)
        $(window).on("keyup", @keyup)
        $("#area").on("mousedown", @touch)
        $("#area").on("mouseup", @untouch)


    touch: (e) =>

        if e.clientX > e.currentTarget.clientWidth / 2

            @action = @step_right

        else

            @action = @step_left

        @down = true


    untouch: (e) =>

        @down = false


    keydown: (e) =>

        switch e.which

            when 39, "d"  # right

                @action = @step_right
                @down = true
                e.preventDefault()

            when 37, "a"  # left

                @action = @step_left
                @down = true
                e.preventDefault()


    keyup: (e) =>

        @down = false


    make_action: (ctx) ->

        @action?(ctx)
        if not @down

            @action = null


    step_left: (ctx) =>

        @x = Math.max(0, @x - @delta)


    step_right: (ctx) =>

        @x = Math.min(ctx.canvas.width - @width, @x + @delta)


    redraw: (ctx) ->

        ctx.beginPath()
        ctx.moveTo(@x, @y)
        ctx.arc(@x, @y, @radius, @sa, @ea, false)
        ctx.closePath()
        ctx.fillStyle = "#fff"
        ctx.fill()


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
        ctx.lineTo(@x, @y)
        ctx.closePath()
        ctx.fillStyle = "#00f"
        ctx.fill()


class Game

    constructor: (@ctx, @static_objects, @platform, @ball, @w, @h, @interval=30) ->

        @timer = setInterval(@iteration, @interval)


    iteration: () =>

        @platform.make_action(@ctx)

        @static_objects.forEach((e) => e.redraw(@ctx))
        @ball.redraw(@ctx)
        @platform.redraw(@ctx)
        @ball.redraw(@ctx)


    stop: () =>

        clearInterval(@timer)


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

init = () ->

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
        new Platform(w / 2, 2 * h, h * 0.02, h * 1.025, 1.45 * Math.PI, 1.55 * Math.PI, w * 0.03),
        new Ball(w / 2, h * 0.8, 1, -1, radius),
        w,
        h
    )

    $(window).resize(() =>
        g.stop()
        init()
    )


$(init)

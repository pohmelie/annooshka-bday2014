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

    constructor: (@x, @y, @width, @height, @type) ->

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

        ctx.fillRect(@x, @y, @width, @height)

    @build_blocks_from_map: (map, sx, sy, width, height) ->

        blocks = []
        iy = 0
        for line in map.split("\n")

            ix = 0
            blocks_line = []
            for ch in line.trim()

                switch ch

                    when "."

                        n = 0

                    when "#"

                        n = 1

                blocks.push(
                    new Block(
                        sx + ix * width,
                        sy + iy * height,
                        width,
                        height,
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


$(() ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20

    ctx.canvas.width = w
    ctx.canvas.height = h

    blocks_map = '''
        .................
        ......##.##......
        .....#..#..#.....
        ......#...#......
        .......#.#.......
        ........#........
        .................
    '''

    static_objects = [new Background("#293134")]
    blk_width = w / blocks_map.split("\n")[0].length
    static_objects = static_objects.concat(Block.build_blocks_from_map(blocks_map, 0, 0, blk_width, h / 12))

    g = new Game(
        ctx,
        static_objects,
        new Platform(w * 0.9 / 2, h * 0.975 - 5, w * 0.1, h * 0.025, 5),
        new Ball(w / 2, h * 0.8, 1, -1, 10),
        w,
        h
    )

)

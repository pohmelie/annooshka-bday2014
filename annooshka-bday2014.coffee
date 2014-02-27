class Background

    constructor: (@ctx, @color) ->

    redraw: () ->

        @ctx.fillStyle = @color
        @ctx.fillRect(0, 0, @ctx.canvas.width, @ctx.canvas.height)


class Platform

    constructor: (@ctx, @x, @y, @width, @height, @delta) ->

    step_left: () ->

        @x = Math.max(0, @x - @delta)

    step_right: () ->

        @x = Math.min(@ctx.canvas.width - @width, @delta)

    redraw: () ->

        console.log(@, @ctx)
        @ctx.fillStyle = "#fff"
        @ctx.fillRect(@x, @y, @width, @height)


class Block

    constructor: (@ctx, @x, @y, @width, @height, @type) ->

    shot: () ->

        @type = Math.max(-1, @type - 1)

    redraw: () ->

        switch @type

            when 1

                @ctx.fillStyle = "#f00"

            when 0

                @ctx.fillStyle = "#0f0"

            when -1

                return

        @ctx.fillRect(@x, @y, @width, @height)

    @build_blocks_from_map: (map, ctx, sx, sy, width, height) ->

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
                        ctx,
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


$(() ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20

    ctx.canvas.width = w
    ctx.canvas.height = h

    blocks_map = '''
        ..................
        .......##.##......
        ......#..#..#.....
        .......#...#......
        ........#.#.......
        .........#........
        ..................
    '''

    b = new Background(ctx, "#293134")
    blk_width = w / blocks_map.split("\n")[0].length
    blks = Block.build_blocks_from_map(blocks_map, ctx, 0, 0, blk_width, h / 12)
    p = new Platform(ctx, w * 0.9 / 2, h * 0.975 - 5, w * 0.1, h * 0.025, 5)
    b.redraw()
    blks.forEach((blk) -> blk.redraw())
    p.redraw()

)

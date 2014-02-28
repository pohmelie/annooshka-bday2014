#= require <blocks.coffee>


class Background

    constructor: (@color) ->


    redraw: (ctx) ->

        ctx.fillStyle = @color
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)


class Block

    constructor: (@x, @y, @radius, @type) ->

        @block = true


    shot: () ->

        if @type != 1

            @type = Math.max(-1, @type - 1)


    visible: () ->

        return @type != -1


    redraw: (ctx) ->

        switch @type

            when 1

                ctx.fillStyle = "#ff2020"

            when 0, 2

                ctx.fillStyle = "#83ff53"

            when -1

                return

        ctx.beginPath()
        ctx.arc(@x, @y, @radius, 0, 2 * Math.PI, false)
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

                    when "o"

                        n = 2

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

        @ball = true
        @collided = []


    distance: (obj) ->

        return Math.sqrt(Math.pow(@x - obj.x, 2) + Math.pow(@y - obj.y, 2))


    check_collision: (obj) ->

        return @distance(obj) <= @radius + obj.radius


    @projection: (x1, y1, x2, y2, x3, y3, direction) ->

        l = Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2))
        sin = (y2 - y1) / l
        cos = (x2 - x1) / l
        nx = x3 * cos + y3 * sin
        ny = -x3 * sin + y3 * cos
        return [nx, ny]


    @collide: (o1, o2) ->

        [beat1, static1] = Ball.projection(o1.x, o1.y, o2.x, o2.y, o1.dx, o1.dy)
        [beat2, static2] = Ball.projection(o1.x, o1.y, o2.x, o2.y, o2.dx, o2.dy)
        [o1.dx, o1.dy] = Ball.projection(o1.x, o2.y, o2.x, o1.y, beat2, static1)
        [o2.dx, o2.dy] = Ball.projection(o1.x, o2.y, o2.x, o1.y, beat1, static2)


    @symmetric_collide: (o, x, y) ->

        [beat, stat] = Ball.projection(o.x, o.y, x, y, o.dx, o.dy)
        [o.dx, o.dy] = Ball.projection(o.x, y, x, o.y, -beat, stat)


    calc_collisions: (objs, w, h) ->

        ncollided = []
        for o in objs.filter((o) => @ isnt o and @check_collision(o))

            if o not in @collided

                if o.ball

                    if @ not in o.collided

                        Ball.collide(@, o)
                        @collided.push(o)

                else if o.block and o.visible()

                    Ball.symmetric_collide(@, o.x, o.y)
                    o.shot()
                    if balls_count < 22

                        objs.push(generate_ball(@radius, w, h))

            ncollided.push(o)

        @collided = ncollided

        if @x < @radius and @dx < 0

            Ball.symmetric_collide(@, -10, @y)

        if @x > w - @radius and @dx > 0

            Ball.symmetric_collide(@, w + 10, @y)

        if @y < @radius and @dy < 0

            Ball.symmetric_collide(@, @x, -10)

        if @y > h - @radius and @dy > 0

            Ball.symmetric_collide(@, @x, h + 10)


    step: (ctx) ->

        @x += @dx
        @y += @dy

    redraw: (ctx) ->

        ctx.beginPath()
        ctx.arc(@x, @y, @radius, 0, 2 * Math.PI, false)
        ctx.lineTo(@x, @y)
        ctx.closePath()
        ctx.fillStyle = "#63bfc7"
        ctx.fill()


generate_ball = (radius, w, h) ->

    return new Ball(
        radius + (w - 2 * radius) * Math.random(),
        h / 4 * (3 + Math.random()),
        h * 0.01 * (Math.random() * 2 - 1),
        h * 0.01 * (Math.random() * 2 - 1),
        radius
    )


class Scene

    constructor: (@ctx, @objects, @w, @h, @interval=100) ->

        @timer = setInterval(@iteration, @interval)


    iteration: () =>

        @objects.forEach((o) => o.calc_collisions?(@objects, @w, @h))
        @objects.forEach((o) => o.step?(@ctx))
        @objects.forEach((o) => o.redraw(@ctx))

    stop: () =>

        clearInterval(@timer)


resize_blocks = (blocks_map, w, h) ->

    lines = blocks_map.split("\n")
    blk_diameter_w = w / lines[0].length
    blk_diameter_h = h / lines.length / 4 * 3
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

balls_count = 1

init = () ->

    $("body").css("background", "#293134")

    ctx = $("#area")[0].getContext("2d")

    w = $(window).width() - 20
    h = $(window).height() - 20

    ctx.canvas.width = w
    ctx.canvas.height = h

    [blocks, radius] = resize_blocks(blocks_map, w, h)
    objects = [].concat(
        new Background("#293134"),
        Block.build_blocks_from_map(blocks, 0, 0, radius),
    )

    for _ in [0...1]

        objects.push(generate_ball(radius, w, h))

    g = new Scene(
        ctx,
        objects,
        w,
        h
    )

    $(window).resize(() =>
        g.stop()
        init()
    )


$(init)

define ->
    # Internal method for recursing bone hierarchy children and resolving them
    _resolve = (name, x, y, scale, length, parentRotation, rotation, children, list) ->
        # Calculate new values by accumulating rotation and converting polar
        # bone vector to cartesian end point. This will be pivot for children.
        rotation += parentRotation
        endX = x + (length * scale * Math.cos(rotation * (Math.PI / 180)))
        endY = y - (length * scale * Math.sin(rotation * (Math.PI / 180)))

        # Push this node on to the result stack
        # TODO: Find a better way to do it than creating a new array
        list.push([name, x, y, endX, endY])

        # Descend to children
        for childName, child of children
            _resolve(childName, endX, endY, scale, child.l, rotation, child.r, child.c, list)

        return list

    # Resolves position of each node of a bone hierarchy and creates a display list
    resolve = (bones, x, y, scale) ->
        k = Object.keys(bones)
        root = bones[k[0]]
        return _resolve(k[0], x, y, scale, root.l, 0, root.r, root.c, [])

    # Example bone data
    bones =
        "hip":
            "r": 0
            "l": 0
            "c":
                "left-thigh":
                    "r": -100
                    "l": 10
                    "c":
                        "left-shin":
                            "r": -15
                            "l": 10
                            "c":
                                "left-foot":
                                    "l": 3
                                    "r": 115
                "right-thigh":
                    "r": -65
                    "l": 10
                    "c":
                        "right-shin":
                            "r": 0
                            "l": 10
                            "c":
                                "right-foot":
                                    "l": 3
                                    "r": 90
                "torso":
                    "r": 90
                    "l": 10
                    "c":
                        "left-shoulder":
                            "r": 0
                            "l": 0
                            "c":
                                "left-bicep":
                                    "r": -145
                                    "l": 4
                                    "c":
                                        "left-forearm":
                                            "r": 15
                                            "l": 5
                                            "c":
                                                "left-hand":
                                                    "r": 15
                                                    "l": 1
                        "right-shoulder":
                            "r": 0
                            "l": 0
                            "c":
                                "right-bicep":
                                    "r": 145
                                    "l": 4
                                    "c":
                                        "right-forearm":
                                            "r": 15
                                            "l": 5
                                            "c":
                                                "right-hand":
                                                    "r": 15
                                                    "l": 1
                        "head":
                            "r": 0
                            "l": 4

    # Example actor data
    actor =
        "bones": bones
        "scale": 5
        "x": 200
        "y": 200

    # Resolve hierarchy to display list
    list = resolve(actor.bones, actor.x, actor.y, actor.scale)
    console.log(list)

    # Setup debug render
    index = list.length # triggers overflow so initial reset happens in loop
    last = Date.now()

    canvas = document.createElement("canvas")
    canvas.width = 640
    canvas.height = 480

    document.body.appendChild(canvas)

    context = canvas.getContext("2d")
    context.strokeWidth = 2

    render = ->
        delta = Date.now() - last
        window.webkitRequestAnimationFrame(render)

        # Steps every second
        if delta >= 1000

            # Overflow; reset
            if index > list.length - 1
                index = 0
                context.fillStyle = "#fff"
                context.fillRect(0, 0, canvas.width, canvas.height)

            e = list[index]
            last = Date.now()
            console.log("#{e[0]}: #{e[1]}, #{e[2]} to #{e[3]}, #{e[4]}")

            # Draw "bone"
            context.beginPath()
            context.moveTo(e[1], e[2])
            context.strokeStyle = "rgba(0, 0, 0, 0.25)"
            context.lineTo(e[3], e[4])
            context.stroke()

            # Draw red start node
            context.beginPath()
            context.fillStyle = "rgba(255, 0, 0, 0.5)"
            context.arc(e[1], e[2], 3, 0, Math.PI*2, false)
            context.fill()

            # Draw blue end node
            context.beginPath()
            context.fillStyle = "rgba(0, 0, 255, 0.5)"
            context.arc(e[3], e[4], 3, 0, Math.PI*2, false)
            context.fill()

            index += 1

    render()

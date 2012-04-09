define ->    
    # Internal method for recursing bone hierarchy children and resolving them
    _resolve = (name, x, y, scale, length, rotation, children, cb, state) ->
        # Calculate new values by accumulating rotation and converting polar
        # bone vector to cartesian end point. This will be pivot for children.
        # Given angles are in degrees so they're converted to radians here too.
        endX = x + (length * scale * Math.cos(rotation * (Math.PI / 180)))
        endY = y - (length * scale * Math.sin(rotation * (Math.PI / 180)))

        # Invoke node callback
        cb(name, x, y, endX, endY, rotation, length * scale, state)

        # Descend to children
        for childName, child of children
            _resolve(childName, endX, endY, scale, child.l, (child.r + rotation) % 360, child.c, cb, state)

        return state

    displayListCallback = (name, x, y, eX, eY, r, l, state) ->
        state.displayList = [] unless state.displayList
        state.displayList.push([name, x, y, eX, eY, r, l])

    # Resolves position of each node of a bone hierarchy and creates a display list
    resolve = (bones, x, y, scale, cb) ->
        cb = displayListCallback unless cb
        k = Object.keys(bones)
        root = bones[k[0]]
        return _resolve(k[0], x, y, scale, root.l, root.r, root.c, cb, {})

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
        "scale": 10
        "x": 200
        "y": 200

    # Resolve hierarchy to display list for debug
    list = resolve(actor.bones, actor.x, actor.y, actor.scale).displayList
    console.log(list)

    # Setup debug render
    last = Date.now()

    canvas = document.createElement("canvas")
    canvas.width = 640
    canvas.height = 480

    document.body.appendChild(canvas)

    context = canvas.getContext("2d")
    
    debugDrawCallback = (name, x, y, eX, eY, r, l, state) ->
        
        # Transform context matrix to bone origin & orientation
        # Canvas uses a different zero degree to unit circle
        context.save()
        context.translate(x, y)
        context.rotate((270 - r) * (Math.PI / 180))
        
        # Init style
        context.fillStyle = "rgba(127, 200, 255, 0.5)"
        context.strokeStyle = "rgba(127, 200, 255, 1.0)"
        
        # Draw bone outline, fill and label
        context.beginPath()
        context.arc(0, 0, 5, 0, Math.PI, true)
        context.lineTo(0, l)
        context.lineTo(5, 0)
        context.fillText(name, 10, l / 2)
        context.fill()
        context.stroke()
        
        # Draw origin circle
        context.beginPath()
        context.fillStyle = "rgba(127, 200, 255, 1.0)"
        context.arc(0, 0, 3, 0, Math.PI * 2, false)
        context.fill()
        
        # Draw origin -> end point line
        context.beginPath()
        context.moveTo(0, 0)
        context.lineTo(0, l)
        context.stroke()
        context.restore()

    render = ->
        delta = Date.now() - last
        last = Date.now()
        window.webkitRequestAnimationFrame(render)
        context.fillRect(0, 0, canvas.width, canvas.height)
        resolve(actor.bones, actor.x, actor.y, actor.scale, debugDrawCallback)

    render()

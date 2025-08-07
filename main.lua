-- Run this to hot reload
-- nodemon --exec "love ." --ext lua --ignore node_modules


local game = {}

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Some of the libs may need love so we require them here
    sti = require("libs/sti/sti")
    anim8 = require("libs/anim8/anim8")
    Camera = require("libs/hump/camera")
    Gamestate = require("libs/hump/gamestate")
    vector = require "libs.hump.vector"
    wf = require("libs/windfield/windfield")

    -- love.physics.setMeter(1) -- 64 pixels = 1 meter
    world = wf.newWorld(0, 0, true)

    -- love.window.setMode(800, 600, {
    --     resizable = true,
    --     -- fullscreen = true,
    -- })

    require("util")
    setToSecondMonitor()

    Gamestate.registerEvents()
    Gamestate.switch(game)
    print("Meter is " .. love.physics.getMeter() .. " pixels")
end

function game:enter()
    map = sti("tiled_map.lua")

    chickenArea = map.layers["Chicken_area"].objects[1]
    local verts = {}
    for i, vert in ipairs(chickenArea.polygon) do
        table.insert(verts, vert.x)
        table.insert(verts, vert.y)
    end
    chickenAreaPolygon = world:newPolygonCollider(verts)
    chickenAreaPolygon:setType("static")
    chickenAreaFixture = chickenAreaPolygon.fixture
    local points = {   chickenAreaPolygon.shape:getPoints()}

    mapWidth  = map.width * map.tilewidth
    mapHeight = map.height * map.tileheight

    require("player")
    setupPlayer()

    require("chicken")
    setupChicken()

    cam = Camera()
    cam:zoomTo(7)
end

function game:update(dt)
    --    print("Player position: (" .. player.x .. ", " .. player.y .. ")") -- Use this for debugging
    -- Update camera
    cam:lookAt(player.x, player.y)

    player.stateMachine:update(dt)
    playerBaseUpdate()

    -- Update chickens
    for _, chicken in ipairs(chickens) do
        if chicken.statemachine then
            chicken.statemachine:update(dt)
        end
    end

    map:update(dt)
    world:update(dt)
end

function game:draw()
    cam:attach()
    map:drawLayer(map.layers["Stone_0"])
    map:drawLayer(map.layers["Ground"])
    map:drawLayer(map.layers["Grass_1"])
    map:drawLayer(map.layers["Extra"])
    map:drawLayer(map.layers["Foliage"])
    player.stateMachine:draw()

    for _, chicken in ipairs(chickens) do
        if chicken.statemachine then
            chicken.statemachine:draw()
        end
    end

    -- Sprites are at top left, so offset it before scale
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, nil, 24, 24)
    world:draw()
    cam:detach()
end

-- https://love2d.org/wiki/Debug
function love.keypressed(key, u)
    -- This is basically a REPL so you can call print from here
    if key == "rctrl" then --set to whatever key you want to use
        debug.debug()
    end
end

function love.wheelmoved(x, y)
    if cam then
        local currentZoom = cam.scale
        if y > 0 then
            cam:zoomTo(math.min(currentZoom + 1, 20))
        elseif y < 0 then
            cam:zoomTo(math.max(currentZoom - 1, 1))
        end
    end
end

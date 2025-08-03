-- Run this to hot reload
-- nodemon --exec "love ." --ext lua --ignore node_modules

vector = require "libs.hump.vector"

local game = {}

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.graphics.setDefaultFilter("nearest", "nearest")
    sti = require("libs/sti/sti")
    anim8 = require("libs/anim8/anim8")
    Camera = require("libs/hump/camera")
    Gamestate = require("libs/hump/gamestate")


    -- love.window.setMode(800, 600, {
    --     resizable = true,
    --     -- fullscreen = true,
    -- })

    require("util")
    setToSecondMonitor()

    Gamestate.registerEvents()
    Gamestate.switch(game)
end

function game:enter()
    map       = sti("tiled_map.lua")

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
    player.anim:update(dt)

    -- Update chickens
    for _, chicken in ipairs(chickens) do
        if chicken.statemachine then
            chicken.statemachine:update(dt)
        end
    end

    map:update(dt)
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
    cam:detach()
end

-- https://love2d.org/wiki/Debug
function love.keypressed(key, u)
    -- This is basically a REPL so you can call print from here
    if key == "rctrl" then --set to whatever key you want to use
        debug.debug()
    end
end

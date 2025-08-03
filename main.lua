-- Run this to hot reload
-- nodemon --exec "love ." --ext lua --ignore node_modules

vector = require "libs.hump.vector"

local game = {}
totalChickens = 20

function love.load()
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
    map                          = sti("tiled_map.lua")

    local mapWidth               = map.width * map.tilewidth
    local mapHeight              = map.height * map.tileheight

    -- Start player at center of the map
    player                       = {
        x = mapWidth / 2,
        y = mapHeight / 2,
        speed = 70
    }

    player.spriteSheet           = love.graphics.newImage(
        "assets/sprout_lands/Characters/Premium Charakter Spritesheet.png")

    player.grid                  = anim8.newGrid(48, 48, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations            = {}
    player.animations.idle_down  = anim8.newAnimation(player.grid('1-8', 1), 0.08) -- idle down animation
    player.animations.idle_left  = anim8.newAnimation(player.grid('1-8', 2), 0.08) -- idle left animation
    player.animations.idle_right = anim8.newAnimation(player.grid('1-8', 3), 0.08) -- idle right animation
    player.animations.idle_up    = anim8.newAnimation(player.grid('1-8', 4), 0.08) -- idle up animation

    -- Running animations (assuming rows 5-8)
    player.animations.run_down   = anim8.newAnimation(player.grid('1-8', 5), 0.08) -- run down animation
    player.animations.run_left   = anim8.newAnimation(player.grid('1-8', 6), 0.08) -- run left animation
    player.animations.run_right  = anim8.newAnimation(player.grid('1-8', 7), 0.08) -- run right animation
    player.animations.run_up     = anim8.newAnimation(player.grid('1-8', 8), 0.08) -- run up animation

    -- Walking animations (assuming rows 9-12)
    player.animations.walk_down  = anim8.newAnimation(player.grid('1-8', 9), 0.10) -- walk down animation
    player.animations.walk_left  = anim8.newAnimation(player.grid('1-8', 10), 0.10) -- walk left animation
    player.animations.walk_right = anim8.newAnimation(player.grid('1-8', 11), 0.10) -- walk right animation
    player.animations.walk_up    = anim8.newAnimation(player.grid('1-8', 12), 0.10) -- walk up animation

    player.anim                  = player.animations.idle_up

    cam                          = Camera()

    chickenPrefab                = {}

    chickens                     = {}
end

function game:update(dt)

     local delta = vector(0,0)
    if love.keyboard.isDown('left') then
        delta.x = -1
    elseif love.keyboard.isDown('right') then
        delta.x =  1
    end
    if love.keyboard.isDown('up') then
        delta.y = -1
    elseif love.keyboard.isDown('down') then
        delta.y =  1
    end
    delta:normalizeInplace()



    --    print("Player position: (" .. player.x .. ", " .. player.y .. ")") -- Use this for debugging


    -- Update camera
    cam:lookAt(player.x, player.y)
    cam:zoomTo(7)

    player.anim:update(dt)

    map:update(dt)
end

function game:draw()
    cam:attach()
    map:drawLayer(map.layers["Stone_0"])
    map:drawLayer(map.layers["Ground"])
    map:drawLayer(map.layers["Grass_1"])
    map:drawLayer(map.layers["Extra"])
    map:drawLayer(map.layers["Foliage"])
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

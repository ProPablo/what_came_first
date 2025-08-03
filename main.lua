-- Load Libraries
local sti = require("libs.STI")
local anim8 = require("libs.anim8")
local Camera = require("libs.hump.camera")
local Gamestate = require("libs.hump.gamestate")

-- Game states
local game = {}

-- Shared state
local map, player, camera, animation

function game:enter()
    -- Load Tiled map
    map = sti("assets/maps/mymap.lua")

    -- Load sprite and set up animation
    local image = love.graphics.newImage("assets/sprites/player.png")
    local g = anim8.newGrid(16, 16, image:getWidth(), image:getHeight()) -- assuming 32x32 sprites
    animation = anim8.newAnimation(g('1-4',1), 0.1) -- 4 frames in first row

    -- Player position
    player = { x = 100, y = 100, speed = 100 }

    -- Setup camera
    camera = Camera(player.x, player.y)
end

function game:update(dt)
    -- Update player movement
    if love.keyboard.isDown("left") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("right") then player.x = player.x + player.speed * dt end
    if love.keyboard.isDown("up") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("down") then player.y = player.y + player.speed * dt end

    -- Update camera
    camera:lookAt(player.x, player.y)

    -- Update animation
    animation:update(dt)

    -- Update map (for parallax, etc.)
    map:update(dt)
end

function game:draw()
    camera:attach()
        map:draw()
        animation:draw(love.graphics.newImage("assets/sprites/player.png"), player.x, player.y)
    camera:detach()
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(game)
end
-- PlayerStates.lua
-- Player-specific states for the state machine

local statemachine = require('libs.statemachine') -- Adjust path as needed
local vector = require('libs.hump.vector')        -- Make sure hump is available
local State = statemachine.State

local IdleState = {}
IdleState.__index = IdleState

function IdleState:new()
    local state = State:new()
    setmetatable(state, IdleState)
    return state
end

function IdleState:onEnter()
    print("Entering Idle State")
    -- Set the appropriate idle animation based on last direction
    local direction = player.lastDirection or "down"
    player.anim = player.animations["idle_" .. direction]
end

function IdleState:onExit()
    print("Exiting Idle State")
end

function IdleState:update(dt)
    -- Create input vector using hump
    local inputVector = vector(0, 0)

    if love.keyboard.isDown("w", "up") then
        inputVector.y = -1
        player.lastDirection = "up"
    elseif love.keyboard.isDown("s", "down") then
        inputVector.y = 1
        player.lastDirection = "down"
    end

    if love.keyboard.isDown("a", "left") then
        inputVector.x = -1
        player.lastDirection = "left"
    elseif love.keyboard.isDown("d", "right") then
        inputVector.x = 1
        player.lastDirection = "right"
    end

    -- If there's input, normalize and save movement vector, then transition to running
    if inputVector:len() > 0 then
        inputVector = inputVector:normalized()
        player.movementVector = inputVector
        self.stateMachine:transitionTo("running")
    end

    -- Update current animation
    if player.anim then
        player.anim:update(dt)
    end
end


-- Running State
local RunningState = {}
RunningState.__index = RunningState

function RunningState:new()
    local state = State:new()
    setmetatable(state, RunningState)
    return state
end

function RunningState:onEnter()
    print("Entering Running State")
    -- Set the appropriate running animation based on movement direction
    local direction = player.lastDirection or "down"
    player.anim = player.animations["run_" .. direction]
end

function RunningState:onExit()
    print("Exiting Running State")
end

function RunningState:update(dt)
    -- Create input vector using hump
    local inputVector = vector(0, 0)

    if love.keyboard.isDown("w", "up") then
        inputVector.y = -1
        player.lastDirection = "up"
    elseif love.keyboard.isDown("s", "down") then
        inputVector.y = 1
        player.lastDirection = "down"
    end

    if love.keyboard.isDown("a", "left") then
        inputVector.x = -1
        player.lastDirection = "left"
    elseif love.keyboard.isDown("d", "right") then
        inputVector.x = 1
        player.lastDirection = "right"
    end

    -- If no input, transition back to idle
    if inputVector:len() == 0 then
        self.stateMachine:transitionTo("idle")
        return
    end

    -- Normalize input vector and store it
    inputVector = inputVector:normalized()
    player.movementVector = inputVector

    -- Move player using vector
    local moveVector = inputVector * player.speed * dt
    player.x = player.x + moveVector.x
    player.y = player.y + moveVector.y

    -- Update animation based on current direction
    local direction = player.lastDirection
    player.anim = player.animations["run_" .. direction]

    -- Update current animation
    if player.anim then
        player.anim:update(dt)
    end
end

function setupPlayer()
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
    player.animations.idle_left  = anim8.newAnimation(player.grid('1-8', 4), 0.08) -- idle left animation
    player.animations.idle_right = anim8.newAnimation(player.grid('1-8', 3), 0.08) -- idle right animation
    player.animations.idle_up    = anim8.newAnimation(player.grid('1-8', 2), 0.08) -- idle up animation

    -- Running animations (assuming rows 5-8)
    player.animations.run_down   = anim8.newAnimation(player.grid('1-8', 5), 0.08) -- run down animation
    player.animations.run_left   = anim8.newAnimation(player.grid('1-8', 8), 0.08) -- run left animation
    player.animations.run_right  = anim8.newAnimation(player.grid('1-8', 7), 0.08) -- run right animation
    player.animations.run_up     = anim8.newAnimation(player.grid('1-8', 6), 0.08) -- run up animation

    -- Walking animations (assuming rows 9-12)
    player.animations.walk_down  = anim8.newAnimation(player.grid('1-8', 9), 0.10)  -- walk down animation
    player.animations.walk_left  = anim8.newAnimation(player.grid('1-8', 12), 0.10) -- walk left animation
    player.animations.walk_right = anim8.newAnimation(player.grid('1-8', 11), 0.10) -- walk right animation
    player.animations.walk_up    = anim8.newAnimation(player.grid('1-8', 10), 0.10) -- walk up animation

    player.anim                  = player.animations.idle_up
    -- Initialize state machine
    player.stateMachine           = statemachine.StateMachine:new()

    -- Idle State
    local idleState              = IdleState:new()
    -- Running State
    local runningState           = RunningState:new()

    -- Add states
    player.stateMachine:addState("idle", idleState)
    player.stateMachine:addState("running", runningState)

    -- Set initial state
    player.stateMachine:transitionTo("idle")
end
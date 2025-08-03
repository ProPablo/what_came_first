totalChickens = 20

local statemachine = require('libs.statemachine') 

local IdleState = {}
IdleState.__index = IdleState
function IdleState:new(chicken)
    local state = State:new()
    setmetatable(state, IdleState)
    state.chicken = chicken

    state.idleTimer = 0
    state.maxIdleTime = love.math.random(2, 5)
    return state
end

function IdleState:onEnter()
    local chicken = self.chicken
    print("Chicken " .. chicken.id .. " is now idle")

    -- Reset idle timer
    self.idleTimer = 0
    self.maxIdleTime = love.math.random(2, 5)
end

function IdleState:update(dt)
    self.idleTimer = self.idleTimer + dt
    self.chicken.animations.idle:update(dt)
    if self.idleTimer >= self.maxIdleTime then
        -- Transition to walking state after idle time
        self.chicken.statemachine:transitionTo("walk")
    end
end

function IdleState:draw()
    local chicken = self.chicken
    chicken.animations.idle:draw(chickenPrefab.spriteSheet, chicken.x, chicken.y, nil, 1, nil, 8, 8)
end

local WalkingState = {}
WalkingState.__index = WalkingState
function WalkingState:new(chicken)
    local state = State:new()
    setmetatable(state, WalkingState)
    state.chicken = chicken

    state.walkTimer = 0
    state.maxWalkTime = love.math.random(1, 3)
    return state
end

function WalkingState:onEnter()
    local chicken = self.chicken
    print("Chicken " .. chicken.id .. " is now walking")

    -- Reset walk timer
    self.walkTimer = 0
    self.maxWalkTime = love.math.random(1, 3)

    -- Set a random direction for the chicken to walk
    chicken.direction = vector(love.math.random(-1, 1), love.math.random(-1, 1)):normalized()
end

function WalkingState:update(dt)
    local chicken = self.chicken
    self.walkTimer = self.walkTimer + dt

    -- Move the chicken in the current direction
    chicken.x = chicken.x + chicken.direction.x * chicken.speed * dt
    chicken.y = chicken.y + chicken.direction.y * chicken.speed * dt

    chicken.animations.walk:update(dt)

    -- Check if the walk time is over
    if self.walkTimer >= self.maxWalkTime then
        -- Transition to idle state after walking
        self.chicken.statemachine:transitionTo("idle")
    end
end

function WalkingState:draw()
    local chicken = self.chicken
    chicken.animations.walk:draw(chickenPrefab.spriteSheet, chicken.x, chicken.y, nil, 1, nil, 8, 8)
end

local CluckingState = {}
CluckingState.__index = CluckingState
function CluckingState:new(chicken)
    local state = State:new()
    setmetatable(state, CluckingState)
    state.chicken = chicken

    state.cluckTimer = 0
    state.maxCluckTime = love.math.random(1, 3)
    return state
end

function CluckingState:onEnter()
    local chicken = self.chicken
    print("Chicken " .. chicken.id .. " is now clucking")

    -- Reset cluck timer
    self.cluckTimer = 0
    self.maxCluckTime = love.math.random(1, 3)
end

function CluckingState:update(dt)
    self.cluckTimer = self.cluckTimer + dt
    self.chicken.animations.cluck:update(dt)

    -- Check if the cluck time is over
    if self.cluckTimer >= self.maxCluckTime then
        -- Transition back to idle state after clucking
        self.chicken.statemachine:transitionTo("idle")
    end
end

function CluckingState:draw()
    local chicken = self.chicken
    chicken.animations.cluck:draw(chickenPrefab.spriteSheet, chicken.x, chicken.y, nil, 1, nil, 8, 8)
end

function setupChicken()
    chickenPrefab                  = {}
    chickens                       = {}
    chickenPrefab.spriteSheet      = love.graphics.newImage(
        "assets/sprout_lands/Animals/Chicken/chicken default.png"
    )
    chickenPrefab.grid             = anim8.newGrid(
        16, 16,
        chickenPrefab.spriteSheet:getWidth(),
        chickenPrefab.spriteSheet:getHeight()
    )

    local animations = {}
    animations.idle = anim8.newAnimation(chickenPrefab.grid('4-4', 1), 1)
    animations.walk = anim8.newAnimation(chickenPrefab.grid('1-8', 3), 0.3)
    animations.cluck = anim8.newAnimation(chickenPrefab.grid('1-7', 2), 0.3)

    for i = 1, totalChickens, 1 do
        local chicken = {
            x = math.random(0, mapWidth),
            y = math.random(0, mapHeight),
            speed = 50,
            statemachine = statemachine.StateMachine:new(),
            id = i,
            animations = animations,
        }

        -- Initialize state machine for chicken
        chicken.statemachine:addState("idle", IdleState:new(chicken))
        chicken.statemachine:addState("walk", WalkingState:new(chicken))
        chicken.statemachine:addState("cluck", CluckingState:new(chicken))

        -- Start in idle state
        chicken.statemachine:transitionTo("idle")

        table.insert(chickens, chicken)
    end
end
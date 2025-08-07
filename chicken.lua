totalChickens = 20

local statemachine = require('libs.statemachine')
local vector = require('libs.hump.vector')

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

    self.idleTimer = 0
    self.maxIdleTime = love.math.random(2, 5)
end

function IdleState:update(dt)
    self.idleTimer = self.idleTimer + dt
    self.chicken.animations.idle:update(dt)
    if self.idleTimer >= self.maxIdleTime then
        -- Pick either walking or clucking state randomly
        if love.math.random() < 0.8 then
            self.chicken.statemachine:transitionTo("walk")
        else
            self.chicken.statemachine:transitionTo("cluck")
        end
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

    -- Reset walk timer
    self.walkTimer = 0
    self.maxWalkTime = love.math.random(1, 3)

    -- Set a random direction for the chicken to walk
    chicken.direction = vector(love.math.random(-1, 1), love.math.random(-1, 1)):normalized()

    self.flipDirection = false
    if chicken.direction.x < 0 then
        self.flipDirection = true
    end
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
        self.chicken.statemachine:transitionTo("idle")
    end
end

function WalkingState:draw()
    local chicken = self.chicken
    local scaleX = self.flipDirection and -1 or 1
    chicken.animations.walk:draw(chickenPrefab.spriteSheet, chicken.x, chicken.y, nil, scaleX, 1, 8, 8)
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
    self.cluckTimer = 0
    self.maxCluckTime = love.math.random(1, 3)
end

function CluckingState:update(dt)
    self.cluckTimer = self.cluckTimer + dt
    self.chicken.animations.cluck:update(dt)
    if self.cluckTimer >= self.maxCluckTime then
        self.chicken.statemachine:transitionTo("idle")
    end
end

function CluckingState:draw()
    local chicken = self.chicken
    chicken.animations.cluck:draw(chickenPrefab.spriteSheet, chicken.x, chicken.y, nil, 1, nil, 8, 8)
end

function setupChicken()
    chickenPrefab             = {}
    chickens                  = {}
    chickenPrefab.spriteSheet = love.graphics.newImage(
        "assets/sprout_lands/Animals/Chicken/chicken default.png"
    )
    chickenPrefab.grid        = anim8.newGrid(
        16, 16,
        chickenPrefab.spriteSheet:getWidth(),
        chickenPrefab.spriteSheet:getHeight()
    )

    for i = 1, totalChickens, 1 do
        local animations = {}
        animations.idle = anim8.newAnimation(chickenPrefab.grid('4-4', 1), 1)
        animations.walk = anim8.newAnimation(chickenPrefab.grid('1-8', 3), 0.08)
        animations.cluck = anim8.newAnimation(chickenPrefab.grid('1-7', 2), 0.1)
        animations.layEgg = anim8.newAnimation(chickenPrefab.grid('1-4', 4), 0.1)

        local spawnPosition = vector(love.math.random(0, mapWidth), love.math.random(0, mapHeight))
        

        spawnPosition.x = love.math.random(chickenArea.x, chickenArea.x + chickenArea.width)
        spawnPosition.y = love.math.random(chickenArea.y, chickenArea.y +chickenArea.height)


        local chicken = {
            x = spawnPosition.x,
            y = spawnPosition.y,
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

    eggPrefab = {
        spriteSheet = love.graphics.newImage(
            "assets/sprout_lands/Animals/Chicken_Egg/Egg_Spritesheet.png"
        ),
        grid = anim8.newGrid(
            16, 16,
            chickenPrefab.spriteSheet:getWidth(),
            chickenPrefab.spriteSheet:getHeight()
        )
    }
    eggAnimations = {}
    eggAnimations.idle = anim8.newAnimation(eggPrefab.grid('1-1', 1), 1)
    eggAnimations.hatch = anim8.newAnimation(eggPrefab.grid('1-4', 1), 0.1)

    eggs = {}
end

-- Helper to get a random point inside the polygon
function getRandomPointInPolygon(polygon, bbox)
    local minX, minY, maxX, maxY = bbox.minX, bbox.minY, bbox.maxX, bbox.maxY
    for _ = 1, 1000 do -- limit attempts
        local x = math.random(minX, maxX)
        local y = math.random(minY, maxY)

    end
    error("Could not find a valid spawn point in chicken_area polygon")
end
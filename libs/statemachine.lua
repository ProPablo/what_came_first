-- StateMachine.lua
-- Simple State Machine for Love2D

StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new()
    local sm = {
        currentState = nil,
        states = {},
        sharedData = {} -- Global shared object for passing data between states
    }
    setmetatable(sm, StateMachine)
    return sm
end

function StateMachine:addState(name, state)
    self.states[name] = state
    state.stateMachine = self -- Give each state access to the state machine
    state.sharedData = self.sharedData -- Give each state access to shared data
end

function StateMachine:transitionTo(stateName, ...)
    if self.currentState and self.currentState.onExit then
        self.currentState:onExit()
    end
    
    self.currentState = self.states[stateName]
    if self.currentState and self.currentState.onEnter then
        self.currentState:onEnter(...)
    end
end

function StateMachine:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateMachine:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

-- Base State class
State = {}
State.__index = State

function State:new()
    local state = {}
    setmetatable(state, State)
    return state
end

function State:onEnter() end
function State:onExit() end
function State:update(dt) end
function State:draw()
    print("Drawing state: " .. self.__name)
end

return {
    StateMachine = StateMachine,
    State = State
}
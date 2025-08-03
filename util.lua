function setToSecondMonitor()
    local targetMonitor = 1 -- Change this to the desired monitor number
    local desktopWidth, desktopHeight = love.window.getDesktopDimensions(targetMonitor)

    love.window.setMode(1200, 800, {
        x = desktopWidth + 30,
        y = 30,
        resizable = true,
    })
end
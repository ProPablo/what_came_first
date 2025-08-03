function setupChicken()
    chickenPrefab = {}

    chickenPrefab.spriteSheet = love.graphics.newImage(
        "assets/sprout_lands/Animals/Chicken/chicken default.png"
    )
    chickenPrefab.grid = anim8.newGrid(
        16, 16,
        chickenPrefab.spriteSheet:getWidth(),
        chickenPrefab.spriteSheet:getHeight()
    )
    chickenPrefab.animations = {}
    chickenPrefab.animations.walk = anim8.newAnimation(chickenPrefab.grid('1-8', 3), 0.10)  -- walking: frames 1-8, row 3
    chickenPrefab.animations.cluck = anim8.newAnimation(chickenPrefab.grid('1-7', 2), 0.12) -- clucking: frames 1-7, row 2
end

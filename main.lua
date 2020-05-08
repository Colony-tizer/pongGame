PLAYERS_SCORE = { 0, 0 }
WINDOWS_SIZE = { 
    w = 1280, 
    h = 720 
}

--
-- startup func
-- set vars etc.
--
function love.load() 
    love.window.setMode(WINDOWS_SIZE.w, WINDOWS_SIZE.h, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end
--
-- Update func dt how many ms past from the last update
--
function love.update(dt) 

end
--
-- Called each frame for drawing things
--
function love.draw()
    love.graphics.printf(
        "Hello, world!",
        0, 
        WINDOWS_SIZE.h / 2,
        WINDOWS_SIZE.w,
        'center'
    )
end
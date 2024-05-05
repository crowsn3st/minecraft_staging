--------------------------------------------------------------------
-- modification to the turtle tunnel program included in the ComputerCraft mod
-- uses turtle inventory first slot for fuel, 2nd for torches, 3rd for stone
-- places torches down to prevent mob spawning, detects and places blocks down to prevent water/lava flooding
-- place turtle on ground level, run app, and the turtle should return to the same X, Z but up 2 on the Y axis
-- usage: "programName X" - programName is the name of your turtle program, X is the length of the tunnel. e.g. "newTunnel 20" - this will dig a tunnel 20 blocks deep
--------------------------------------------------------------------

-- Make sure this is a Turtle robot
if not turtle then
    printError('Requires a Turtle')
    return
end

-- Ask for length of tunnel
local tArgs = { ... }
if #tArgs ~= 1 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print('Usage: ' .. programName .. ' <length>')
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local departureLength = tonumber(tArgs[1])
if departureLength < 1 then
    print('Tunnel length must be positive')
    return
end

-- Track number of collected items
local collected = 0
local function collect()
    collected = collected + 1
    --[[if math.fmod(collected, 25) == 0 then
        print('Mined ' .. collected .. ' items.')
    end]] -- maybe we can tweak this later
end

-- Setting length for return trip
local returnLength = departureLength

-- Refuel function
local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == 'unlimited' or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print('Add more fuel nigga')
        while not tryRefuel() do
            os.pullEvent('turtle_inventory')
        end
        print('Resuming Tunnel.')
    end
end

-- A lot of digging
-- Try digging forward in front
local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

-- Try digging up
local function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

-- Try digging down
local function tryDigDown()
    while turtle.detectDown() do
        if turtle.digDown() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

-- A lot of moving
-- Try moving up
local function tryUp()
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
                return false
            end
        elseif turtle.attackUp() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

-- Try moving down
local function tryDown()
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown() then
                return false
            end
        elseif turtle.attackDown() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

-- Try moving forward
local function tryForward()
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then
                return false
            end
        elseif turtle.attack() then
            collect()
        else
            sleep(0.5)
        end
    end
    return true
end

-- Turn Left
local function turnLeft()
    turtle.turnLeft()
end

-- Turn Right
local function turnRight()
    turtle.turnRight()
end

-- Turn around function
local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
    sleep(0.4)
end

-- Detect block in front
local function detect() 
    if turtle.detect() then
        return
        sleep(0.3)
    else
        --print('placing block...')
        turtle.select(1)
        turtle.place()
    end
end

-- Detect block above
local function detectUp() 
    if turtle.detectUp() then
        return
        sleep(0.3)
    else
        --print('placing block...')
        turtle.select(3)
        turtle.placeUp()
    end
end

-- Detect block below
local function detectDown() 
    if turtle.detectDown() then
        return
        sleep(0.3)
    else
        --print('placing block...')
        turtle.select(3)
        turtle.placeDown()
    end
end

-- Vertical movement
-- Go up two blocks and turn around, added top back wall algo
local function elevate()
    tryUp()
    tryUp()
    detect()
    turtle.turnLeft()
    tryDig()
    tryForward()
    detect()
    turtle.turnRight()
    detect()
    tryUp()
    detect()
    detectUp()
    turtle.turnLeft()
    detect()
    turnAround()
    tryDig()
    tryForward()
    detectUp()
    turtle.turnLeft()
    detect()
    turtle.turnRight()
    tryDig()
    tryForward()
    detect()
    detectUp()
    turtle.turnLeft()
    detect()
    tryDown()
    detect()
    turtle.turnRight()
    detect()
    turnAround()
    tryForward()
    turtle.turnLeft()
end

-- Go down two blocks and turn around
local function descend()
    tryDown()
    tryDown()
    turtle.turnRight()
end

-- Clean up last few blocks
local function cleanUp()
    turtle.forward()
    turtle.digUp()
    turtle.turnLeft()
    turtle.dig()
    turnAround()
    turtle.dig()
    turtle.up()
    turtle.dig()
    turnAround()
    turtle.dig()
    sleep(0.3)
end

-- Roundtrip
-- Departure trip
local function departureTrip()
    for n = 0, departureLength do
        --tryDigUp()
        detect()
        detectDown()
        turnLeft()
        tryDig()
        tryForward()
        detectDown()
        turnRight()
        detect()
        tryUp()
        detect()
        turnLeft()
        detect()
        detectUp()
        turnAround()
        tryDig()
        tryForward()
        detectUp()
        turnLeft()
        detect()
        turnRight()
        tryDig()
        tryForward()
        detect()
        detectUp()
        turnLeft()
        detect()
        tryDown()
        detect()
        detectDown()
        turnRight()
        detect()
        turnAround()
        tryForward()

        -- Place torch down every 10 blocks
        if n % 11 == 0 then
            --print('divisible by 11')
            turnLeft()
            turtle.select(15)
            turtle.place()
            turnAround()
            sleep(0.2)
        else
            --print('not divisible by 11')
            turnRight()
            sleep(0.3)
        end
        
        if n < departureLength then
            tryDig(print('departure swing'))
            if not tryForward() then 
                print('Aborting Tunnel.\n')
                break
            end
        else
            -- Place torch at end of tunnel to try to cover mob spawns
            turtle.dig()
            turtle.select(2)
            turtle.place()
            --returnHome()
            --print('Departure Sequence complete.')
        end
    end
end

-- Returning trip
local function returnTrip()
    for n = 0, returnLength do
        --tryDigUp()
        detect()
        turnLeft()
        tryDig()
        tryForward()
        detect()
        turnRight()
        detect()
        tryUp()
        detect()
        detectUp()
        turnLeft()
        detect()
        turnAround()
        tryDig() -- might not need this
        tryForward()
        detectUp()
        turnLeft()
        detect()
        turnRight()
        tryDig()
        tryForward()
        detect()
        detectUp()
        turnLeft()
        detect()
        tryDown()
        detect()
        turnRight()
        detect()
        turnAround()
        tryForward()
        turnRight()
        tryDig()

        if n < returnLength then
            tryDig(print'returning swing')
            if not tryForward() then 
                print('Aborting Tunnel.\n')
                break
            end
        else
            -- run cleanup
            cleanUp()
            --returnHome()
            --print('Return Sequence complete.')
        end
    end
end

-- Return to starting point
local function returnHome() -- currently using roundtrip instead to dig taller tunnel
    print('Returning to starting point...')
    turnAround()
    returnLength = returnLength - 1
    while returnLength > 0 do
        if turtle.forward() then
            returnLength = returnLength - 1
        else
            turtle.dig()
        end
    end
    turnAround()
end

-- Run program
local function run()
    currentFuelLevel = turtle.getFuelLevel()
    term.clear()
    print('Boring Co.: Tunnelling...')
    print('Fuel level: ' .. currentFuelLevel .. '\n')

    departureTrip()
    elevate()
    returnTrip()
    descend()

    print('Tunnel complete.\n')
    print('Boring Co.: Mined ' .. collected .. ' items total.')
    print('Fuel Level: ' .. currentFuelLevel .. '\n')
end

run()

--[[
    if math.fmod(collected, 25) == 0 then
        print('Mined ' .. collected .. ' items.')
    end
]] -- maybe we use this part to place torches down automatically


--NEED: functionality to detect block that explodes so turtle can avoid. 
--NEED: functionality to read inventory items. (forgot why we needed this)
--NEED: need loop logic to ignore first loop, since 0 will % to 0 then we need to ignore the first loop
--NEED: also loop logic to ignore last loop, don't want turtle to put extra blocks in the end

objects = {}
rooms = {}
lookup = {}
function lookup.__index(self, i) return self.base[i] end

__object = {
    x = 64,
    y = 30,
    id = -1,
    offsetX = 0,
    offsetY = 0,
    animationFrame = "down",
    shouldFlip = false,
    animations = {},
    shouldCheckDoors = false,
    speech = "No one ever came to talk to me before. I really don't know what to say.",
    sprites = {
        up = 99,
        down = 96,
        leftRight = 102,
        stepLeftRight = 104,
        stepUp = 100,
        stepDown = 97,
    }
}

__room = {
    x = 0,
    y = 0,
    maxX = 128,
    maxY = 64,
    doors = {
        -- {
        --     x = 14,
        --     y = 2,
        --     roomNumber = 2,
        --     destination = {
        --         x = 14,
        --         y = 18
        --     }
        -- }
    },
    bottomExitDoors = {}
}

function __object.setSprites(self, up, down, leftRight, stepLeftRight, stepUp, stepDown)
    self.sprites = {
        up = up,
        down = down,
        leftRight = leftRight,
        stepLeftRight = stepLeftRight,
        stepUp = stepUp,
        stepDown = stepDown
    }
end

function __object.runAnimations(self)
    if (#self.animations == 0) then
        self.offsetX = 0
        self.offsetY = 0
        if self.shouldCheckDoors then
            self.shouldCheckDoors = false
            -- checkDoors()
            -- Check doors shouldn't be part of the animation loop
            -- There should be an easier way to trigger an animation for this
            -- Maybe it's part of the check for solid blocks?
        end
        return false
    end

    local firstFrame = del(self.animations, self.animations[1])
    if firstFrame.type == "callback" then
        firstFrame.callback()
        return
    end
    self.animationFrame = firstFrame.animationFrame
    self.offsetX = firstFrame.x
    self.offsetY = firstFrame.y

    if #self.animations == 0 then
        self.shouldCheckDoors = true
    end

    return true
end

function __object.draw(self, x, y)
    local spriteY = y - 4 -- Characters draw high
    local s = self.sprites

    -- Animations are 15 frames
    -- stand 6 frames, step 8 frames, first frame of next animation
    if player.animationFrame == "up" then
        spr(s.up, x, spriteY, 1, 2, false, false)
        spr(s.up, x + 8, spriteY, 1, 2, true, false)
    elseif player.animationFrame == "down" then
        spr(s.down, x, spriteY, 1, 2, false, false)
        spr(s.down, x + 8, spriteY, 1, 2, true, false)
    elseif player.animationFrame == "left" then
        spr(s.leftRight, x, spriteY, 2, 2, false, false)
    elseif player.animationFrame == "right" then
        spr(s.leftRight, x, spriteY, 2, 2, true, false)
    elseif player.animationFrame == "step_right" then
        spr(s.stepLeftRight, x, spriteY, 2, 2, true, false)
    elseif player.animationFrame == "step_left" then
        spr(s.stepLeftRight, x, spriteY, 2, 2, false, false)
    elseif player.animationFrame == "step_up" then
        spr(s.stepUp, x, spriteY, 2, 2, false, false)
    elseif player.animationFrame == "step_down" then
        spr(s.stepDown, x, spriteY, 2, 2, false, false)
    end
end

function __room.checkDoors(self, player)
    for door in all(self.doors) do
        if door.x == player.x and door.y == player.y then
            return true
        end
    end
    return false
end

function __room.isInRoom(self, x, y)
    -- Some rooms have exit doors on the bottom that are "outside the room"
    for door in all(self.bottomExitDoors) do
        if door.x == x and door.y == y then
            return true
        end
    end

    return x >= self.x and x < self.maxX and y >= self.y and y < self.maxY
end

function __room.isPassable(self, x, y)
    -- Some rooms have exit doors on the bottom that are "outside the room"
    for door in all(self.bottomExitDoors) do
        if door.x == x and door.y == y then
            return true
        end
    end

    return not fget(mget(x, y), 0)
end

function __room.addDoor(self, x, y, roomNumber, destX, destY)
    local door = {
        x = x,
        y = y,
        roomNumber = roomNumber,
        destination = {
            x = destX,
            y = destY
        }
    }
    add(self.doors, door)
end

function create(x, y)
    local obj = {}
	obj.base = __object
	obj.x = x
	obj.y = y
	setmetatable(obj, lookup)
	add(objects, obj)
	if obj.init then obj.init(obj) end
	return obj
end

function createRoom(x, y, maxX, maxY)
    local obj = {}
	obj.base = __room
	obj.x = x
	obj.y = y
    obj.maxX = maxX
    obj.maxY = maxY
	setmetatable(obj, lookup)
	add(rooms, obj)
	if obj.init then obj.init(obj) end
	return obj
end
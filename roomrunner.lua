-- INIT ***********************
RoomRunner = {}
RoomRunner.pal = {
    {1, 1}
}
RoomRunner.cam = {
    x=0, y=0
}
RoomRunner.player = nil
RoomRunner.focusedPlayer = nil
RoomRunner.room = nil
RoomRunner.activeText = nil
RoomRunner.textScroll = 0
RoomRunner.blink = 0
RoomRunner.players = {}
RoomRunner.pallete = nil
RoomRunner.triggerFunction = nil
RoomRunner.pauseInput = false
RoomRunner.animatedTiles = {}
RoomRunner.frameCount = 0
RoomRunner.textTriggers = {}

-- UPDATE *******************

function RoomRunner.update(self)
    -- if activeTransition != nil then
    --     return
    -- end

    if self.activeText != nil then
        self:scrollText()
        self:receiveTextInput()
    elseif (not self.player:runAnimations()) then
        self:receiveInput()
    end

    self:runAnimations()
    -- end
end

function RoomRunner.receiveInput(self)
    if self.pauseInput then return end

    if (btn(0)) then
        self:tryMove(-1, 0, "left")
    elseif (btn(1)) then
        self:tryMove(1, 0, "right")
    elseif (btn(2)) then
        self:tryMove(0, -1, "up")
    elseif (btn(3)) then
        self:tryMove(0, 1, "down")
    elseif (btnp(4)) then
        printh("Z")
    elseif (btnp(5)) then
        self:inspect()
    end
end

function RoomRunner.receiveTextInput(self)
    if self.pauseInput then return end

    -- Keeping separate because in the real game one button scrolls text faster, I might decide to build that
    if (btnp(4)) then
        self:nextMessage(true)
    elseif (btnp(5)) then
        self:nextMessage(false)
    end
end

function RoomRunner.scrollText(self)
    if self.textScroll % 6 != 0 then
        self.textScroll += 1
    end
end

function RoomRunner.scrollSound(self)
    -- print("\ace-g")
    -- print("\as4x5c1egc2egc3egc4")
    print("\aa1")
end

function RoomRunner.nextMessage(self, fast)
    -- If we have long text, scroll it
    if self.activeText != nil then
        local count = #split(self.activeText, "\n")
        if count > 3 and self.textScroll < (count - 4) * 6 then
            if fast then
                self.textScroll += 6
            else
                self.textScroll += 1
            end
            self:scrollSound()
            return
        end
    end

    -- One point for trigger interception. Call before clearing state.
    if self.triggerFunction != nil then
        self.triggerFunction()
    end

    self.activeText = nil
    self.focusedPlayer = nil
    self.textScroll = 0
end

function RoomRunner.runAnimations(self)
    for player in all(self.players) do
        if player != self.player then
            player:runAnimations()
        end
    end
end

function RoomRunner.tryMove(self, x, y, frame)
    self.player.animationFrame = frame

    -- Check collision on next 2 sprite tiles
    local newX = self.player.x
    local newY = self.player.y
    for point in all({1, 2}) do
        newX = self.player.x + x * point
        newY = self.player.y + y * point
        if not self.room:isInRoom(newX, newY) or not self:isPassable(newX, newY) then
            return
        end
    end

    self:move(self.player, x, y, frame)
end

function RoomRunner.move(self, player, x, y, frame)
    -- Build the list of animation frames to draw
    player.animations = {}
    add(player.animations, {animationFrame=frame, x=-x * 14, y=-y * 14})

    for i in all({12,10,8,6}) do
        add(player.animations, {animationFrame="step_"..frame, x=-x * i, y=-y * i})
    end

    for i in all({4,2}) do
        add(player.animations, {animationFrame=frame, x=-x * i, y=-y * i})
    end

    player.x = player.x + x * 2
    player.y = player.y + y * 2
    player.offsetX = -x * 16
    player.offsetY = -y * 16
end

function RoomRunner.isPassable(self, x, y)
    for player in all(self.players) do
        if (player != self.player and (player.x == x and player.y == y)) then
            return false
        end
    end

    return self.room:isPassable(x, y)
end

function RoomRunner.inspect(self)
    local player = self.player
    if player.animationFrame == "up" then
        self:inspectAt(player.x, player.y - 2)
    elseif player.animationFrame == "down" then
        self:inspectAt(player.x, player.y + 2)
    elseif player.animationFrame == "left" then
        self:inspectAt(player.x - 2, player.y)
    elseif player.animationFrame == "right" then
        self:inspectAt(player.x + 2, player.y)
    end
end

function RoomRunner.inspectAt(self, x, y)
    for player in all(self.players) do
        if (player != self.player) and (player.x == x and player.y == y) then
            self.activeText = player.speech
            self.focusedPlayer = player
            self:scrollSound()
            return
        end
    end

    for trigger in all(self.textTriggers) do
        if x == trigger.x and y == trigger.y then
            self.activeText = trigger.text
            self:scrollSound()
            return
        end
    end
end

-- DRAW *******************

function RoomRunner.draw(self)
    cls()
    self:pal()
    self:moveCamera()
    self:drawRoom()
    self:drawPlayers()
    self:drawMessage()
    -- drawScreenEffect()

    self.frameCount += 1
end

function RoomRunner.pal(self)
    if self.pallete == nil then return end
    for i=1,#self.pallete do
        pal(i, self.pallete[i + 1], 1)
    end
end

function RoomRunner.moveCamera(self)
    local player = self.player
    self.cam.x = player.x * 8 - 56 + player.offsetX -- max(0,min(player.x - 56, 897))
    self.cam.y = player.y * 8 - 56 + player.offsetY-- max(0,min(player.y - 56,385))
    camera(self.cam.x, self.cam.y)
end

function RoomRunner.drawRoom(self)
    local room = self.room
    map(room.x, room.y, room.x * 8, room.y * 8, room.maxX - room.x + 1, room.maxY - room.y + 1)

    for tile in all(self.animatedTiles) do
        local index = flr(self.frameCount / tile.cadence) % #tile.sprites
        spr(tile.sprites[index + 1], tile.x, tile.y)
    end
end

function RoomRunner.drawPlayers(self)
    for p in all(self.players) do
        self:drawPlayerAt(p.x * 8 + p.offsetX, p.y * 8 + p.offsetY, p)
    end
    -- local p = self.player
    -- self:drawPlayerAt(p.x * 8 + p.offsetX, p.y * 8 + p.offsetY, p)
end

function RoomRunner.drawPlayerAt(self, drawX, drawY, player)
    local x = drawX
    local y = drawY -- Bounding box
    local spriteY = y - 4 -- Player sprite
    local frame = player.animationFrame

    -- Look at me when I'm talking to you!
    if player == self.focusedPlayer then
        if player.x < self.player.x then
            frame = "right"
        elseif player.x > self.player.x then
            frame = "left"
        elseif player.y < self.player.y then
            frame = "down"
        elseif player.y > self.player.y then
            frame = "up"
        end
    end

    -- Animations are 15 frames
    -- stand 6 frames, step 8 frames, first frame of next animation
    local s = player.sprites
    if frame == "up" then
        spr(s.up, x, spriteY, 1, 2, false, false)
        spr(s.up, x + 8, spriteY, 1, 2, true, false)
    elseif frame == "down" then
        spr(s.down, x, spriteY, 1, 2, false, false)
        spr(s.down, x + 8, spriteY, 1, 2, true, false)
    elseif frame == "left" then
        spr(s.leftRight, x, spriteY, 2, 2, false, false)
    elseif frame == "right" then
        spr(s.leftRight, x, spriteY, 2, 2, true, false)
    elseif frame == "step_right" then
        spr(s.stepLeftRight, x, spriteY, 2, 2, true, false)
    elseif frame == "step_left" then
        spr(s.stepLeftRight, x, spriteY, 2, 2, false, false)
    elseif frame == "step_up" then
        spr(s.stepUp, x, spriteY, 2, 2, false, false)
    elseif frame == "step_down" then
        spr(s.stepDown, x, spriteY, 2, 2, false, false)
    end
end

function RoomRunner.drawMessage(self)
    local activeText = self.activeText
    if activeText == nil then
        return
    end

    camera(0, 0)
    rectfill(0, 80, 128, 128, 7)
    
    rect(4, 82, 124, 124, 1)
    rect(2, 84, 126, 122, 1)

    -- Text
    clip(4, 85, 120, 29)
    print(activeText, 8, 90 - self.textScroll, 1)
    clip()
    -- Arrow
    if self.blink < 16 then
        print("\151", 114, 114)
    elseif self.blink >= 32 then
        self.blink = 0
    end
    self.blink = self.blink + 1
end

function RoomRunner.addPlayer(self, player)
    add(self.players, player)
end

function RoomRunner.removePlayer(self, player)
    del(self.players, player)
end

function RoomRunner.addMainPlayer(self, player)
    self.player = player
    add(self.players, player)
end

function RoomRunner.createPlayer(self, x, y, up, down, leftRight, stepLeftRight, stepUp, stepDown, frame)
    local player = create(x, y)
    player:setSprites(up, down, leftRight, stepLeftRight, stepUp, stepDown)
    if frame != nil then player.animationFrame = frame end
    self:addPlayer(player)
end

function RoomRunner.addAnimatedTile(self, x, y, cadence, sprites)
    add(self.animatedTiles, {
        sprites = sprites,
        cadence = cadence,
        x = x,
        y = y
    })
end

function RoomRunner.addTextTrigger(self, x, y, text)
    add(self.textTriggers, {x=x, y=y, text=text})
end
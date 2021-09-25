pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

function _init()
    cartdata("study_in_emerald")
    fadeCounter = 1
    fadeTable = {0, 1, 2, 5, 13, 14, 15, 7}
    duration = 160
    speed = 4
end

function _draw()
    cls()
    if fadeCounter < duration - #fadeTable * speed then
        local index = min(flr(fadeCounter / speed), #fadeTable)
        pal(7, fadeTable[index], 1)
    else
        local index = min(flr((duration - fadeCounter) / speed), #fadeTable)
        pal(7, fadeTable[index], 1)
    end
    print("sTORY BY: nEIL gAIMAN",22,56,7)
end

function _update()
    fadeCounter += 1
    if fadeCounter >= duration then
        load("221b")
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

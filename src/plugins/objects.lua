---@diagnostic disable: undefined-field

local index = 0
local previousGroup = -1

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, 275), imgui.Cond.Once)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(168, 75), imgui.ImVec2(168, 500))
    imgui.Begin("Объекты", nil, (imgui.WindowFlags.NoSavedSettings or 0))
    tooltip("Все объекты текущей группы [1-9, 0]")

    for i = 0, storage.totalGameobjs:readInt() - 1, 1 do
        local name = storage.gameobjsPool:add(52 * i)
        local group = name:add(48)
        local cg = storage.currentGroup:readInt()
        if group:readInt() == cg then
            if previousGroup ~= cg then
                previousGroup = cg
                storage.currentGameobj:writeInt(-1)
            end
            index = index + 1
            if imgui.Selectable_Bool(string.format("%i. %s", index, name:readString()),
                    storage.currentMode:readInt() == 4 and i == storage.currentGameobj:readInt()) then
                storage.dunno3_objects:writeInt(0)
                storage.currentGameobj:writeInt(i)
                local d2 = storage.dunno2_objects:readInt()
                if d2 ~= 0 then
                    storage.dunno1_objects(d2, 1)
                end
                storage.dunno2_objects:writeInt(storage.gameobjCreate(i))
                storage.dunno3_objects:writeInt(4)
                storage.dunno4_objects()
            end
        end
    end
    index = 0

    imgui.End()
end
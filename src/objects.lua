local totalObjects = memory.at("3B 0D ? ? ? ? 7D ? 8B 55 ? 6B D2 ? A1"):add(2):readOffset()
local gameobjsPool = memory.at("81 C2 ? ? ? ? 52 8B 45 ? 83 C0"):add(2):readOffset()
local gameobjsIndex = memory.at("A3 ? ? ? ? 83 3D ? ? ? ? ? 74 ? 8B 0D"):add(1):readOffset()
local dunno = memory.at("E8 ? ? ? ? 89 45 ? EB ? C7 45 ? ? ? ? ? A1"):readNearCall():getFunction("int (__thiscall *)(int, char)")
local dunno2 = memory.at("83 3D ? ? ? ? ? 74 ? 8B 0D"):add(2):readOffset()
local entityCreate = memory.at("E8 ? ? ? ? 83 C4 ? A3 ? ? ? ? 8B 55"):readNearCall():getFunction("int (__cdecl *)(int)")
local dunno3 = memory.at("83 3D ? ? ? ? ? 0F 85 ? ? ? ? 83 3D"):add(2):readOffset()
local dunno4 = memory.at("55 8B EC 83 EC ? 6A ? 6A ? 68"):getFunction("bool (*)()")
local selectedNameAddr = memory.at("A3 ? ? ? ? E8 ? ? ? ? 8B E5 5D C3 5C"):add(1):readOffset()

local index = 0
local previousGroup = -1

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, 275), imgui.Cond.Once)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(168, 75), imgui.ImVec2(168, 500))
    imgui.Begin("Объекты", nil, (imgui.WindowFlags.NoSavedSettings or 0))
    tooltip("Все объекты текущей группы [1-9, 0]")

    for i = 0, totalObjects:readInt() - 1, 1 do
        local name = gameobjsPool:add(52 * i)
        local group = name:add(48)
        local cg = currentGroup:readInt()
        if group:readInt() == cg then
            if previousGroup ~= cg then
                previousGroup = cg
                gameobjsIndex:writeInt(-1)
            end
            index = index + 1
            local selectedName = selectedNameAddr:readInt() == 0 and "" or selectedNameAddr:readOffset():readString()
            if imgui.Selectable_Bool(string.format("%i. %s", index, name:readString()), selectedName == name:readString()) then
                dunno3:writeInt(0)
                gameobjsIndex:writeInt(i)
                local d2 = dunno2:readInt()
                if d2 ~= 0 then
                    dunno(d2, 1)
                end
                dunno2:writeInt(entityCreate(i))
                dunno3:writeInt(4)
                dunno4()
            end
        end
    end
    index = 0

    imgui.End()
end
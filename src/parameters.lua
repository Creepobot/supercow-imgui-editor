local levelBackPool = memory.at("05 ? ? ? ? 89 45 ? C7 45"):add(1):readOffset()
local levelBackAmount = memory.at("89 0D ? ? ? ? 8B 55 ? 0F BE 02"):add(2):readOffset()
local levelTaskPool = memory.at("C1 E2 ? 81 C2 ? ? ? ? 52 6A"):add(5):readOffset()
local levelMusicAmount = memory.at("8B 0D ? ? ? ? 89 04 8D"):add(2):readOffset()
local levelMusicPool = memory.at("81 C1 ? ? ? ? 51 6A ? 68"):add(2):readOffset()

local curBackIndex = memory.at("A1 ? ? ? ? 69 C0 ? ? ? ? 05 ? ? ? ? 89 45 ? C7 45"):add(1):readOffset()
local curTaskIndex = curBackIndex:add(4)
local curMusicIndex = curTaskIndex:add(4)

local callOnce = true
local curBackName
local curTaskName
local curMusicName

return function()
    if callOnce then
        callOnce = false

        curBackName = levelBackPool:add(996 * curBackIndex:readInt()):readString(32)
        curTaskName = levelTaskPool:add(32 * curTaskIndex:readInt()):readString(32)
        curMusicName = levelMusicPool:add(32 * curMusicIndex:readInt()):readString(32)
    end

    imgui.SetNextWindowPos(imgui.ImVec2(0, 0), imgui.Cond.Once)
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Основы", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))
    imgui.PushItemWidth(-1)

    imgui.Text("Задание")
    if imgui.BeginCombo("###levelTaskCombo", curTaskName) then
        for i = 0, 6 - 1, 1 do
            local task = levelTaskPool:add(32 * i):readString()
            local isSelected = curTaskName == task
            if imgui.Selectable(task, isSelected) then
                curTaskIndex:writeInt(i)
                curTaskName = task
            end
            if isSelected then
                imgui.SetItemDefaultFocus()
            end
        end
        imgui.EndCombo()
    end

    imgui.Text("Фон")
    if imgui.BeginCombo("###levelBackCombo", curBackName) then
        for i = 0, levelBackAmount:readInt() - 2, 1 do
            local back = levelBackPool:add(996 * i):readString(32)
            local isSelected = curBackName == back
            if imgui.Selectable(back, isSelected) then
                curBackIndex:writeInt(i)
                curBackName = back
            end
            if isSelected then
                imgui.SetItemDefaultFocus()
            end
         end
        imgui.EndCombo()
    end

    imgui.Text("Музыка")
    if imgui.BeginCombo("###levelMusicCombo", curMusicName) then
        for i = 0, levelMusicAmount:readInt() - 1, 1 do
            local music = levelMusicPool:add(32 * i):readString(32)
            local isSelected = curMusicName == music
            if imgui.Selectable(music, isSelected) then
                curMusicIndex:writeInt(i)
                curMusicName = music
            end
            if isSelected then
                imgui.SetItemDefaultFocus()
            end
        end
        imgui.EndCombo()
    end

    mainBlockPos = imgui.GetWindowPos()
    mainBlockSize = imgui.GetWindowHeight()
    imgui.End()
end
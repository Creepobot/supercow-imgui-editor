local curBackName
local curTaskName
local curMusicName

local initEditorLevelHook
initEditorLevelHook = storage.initEditorLevelAddr:hook("int (*)()", function()
    local idiNahooy = initEditorLevelHook.orig()
    if idiNahooy ~= 2 then
        curBackName = storage.levelBackPool:add(996 * storage.currentBack:readInt()):readString(32)
        curTaskName = storage.levelTaskPool:add(32 * storage.currentTask:readInt()):readString(32)
        curMusicName = storage.levelMusicPool:add(32 * storage.currentMusic:readInt()):readString(32)
    end
    return idiNahooy
end)

local callOnce = true


return function()
    if callOnce then
        callOnce = false

        curBackName = storage.levelBackPool:add(996 * storage.currentBack:readInt()):readString(32)
        curTaskName = storage.levelTaskPool:add(32 * storage.currentTask:readInt()):readString(32)
        curMusicName = storage.levelMusicPool:add(32 * storage.currentMusic:readInt()):readString(32)
    end

    imgui.SetNextWindowPos(imgui.ImVec2(0, 0), imgui.Cond.Once)
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Основы", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))
    imgui.PushItemWidth(-1)

    imgui.Text("Задание")
    if imgui.BeginCombo("###levelTaskCombo", curTaskName) then
        for i = 0, 6 - 1, 1 do
            local task = storage.levelTaskPool:add(32 * i):readString()
            local isSelected = curTaskName == task
            if imgui.Selectable(task, isSelected) then
                storage.currentTask:writeInt(i)
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
        for i = 0, storage.levelBackCount:readInt() - 2, 1 do
            local back = storage.levelBackPool:add(996 * i):readString(32)
            local isSelected = curBackName == back
            if imgui.Selectable(back, isSelected) then
                storage.currentBack:writeInt(i)
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
        for i = 0, storage.levelMusicCount:readInt() - 1, 1 do
            local music = storage.levelMusicPool:add(32 * i):readString(32)
            local isSelected = curMusicName == music
            if imgui.Selectable(music, isSelected) then
                storage.currentMusic:writeInt(i)
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
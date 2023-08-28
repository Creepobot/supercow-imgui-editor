---@diagnostic disable: undefined-field

currentEditorStage = ffi.new("int[1]", 1)
currentEditorLevel = ffi.new("int[1]", 1)

local clearLevelDialog = false
local callOnce = true

return function()
    if callOnce then
        callOnce = false

        currentEditorStage[0] = storage.currentStage:readInt() + 1
        currentEditorLevel[0] = storage.currentLevel:readInt() + 1
    end

    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetMainViewport().WorkSize.x - 168, 0), imgui.Cond.Once)
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Уровень", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))
    imgui.PushItemWidth(-1)

    --imgui.Text("Текущий путь:")
    --imgui.InputText("###zalupaEbanaya", storage.levelFileName, 64, imgui.InputTextFlags.ReadOnly or 0)
    --imgui.Dummy(imgui.ImVec2(0,2.5))

    imgui.Text("Этап")
    if imgui.InputInt("###stageInputInt", currentEditorStage) then
        storage.currentEditorStage:writeInt(currentEditorStage[0] - 1)
        storage.initEditorLevel()
    end
    tooltip("Переключить номер этапа")

    imgui.Text("Уровень")
    if imgui.InputInt("###levelInputInt", currentEditorLevel) then
        storage.currentEditorLevel:writeInt(currentEditorLevel[0] - 1)
        storage.initEditorLevel()
    end
    tooltip("Переключить номер уровня")

    imgui.Dummy(imgui.ImVec2(0,2.5))

    if imgui.Button("CL", imgui.ImVec2(32, 24)) then
        clearLevelDialog = true
    end
    tooltip("Очистить уровень")

    if clearLevelDialog then
        imgui.OpenPopup("Внимание!###clearLevelCaution")
    end

    imgui.SetNextWindowPos(imgui:GetMainViewport():GetCenter(), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
    if imgui.BeginPopupModal("Внимание!###clearLevelCaution", nil, (imgui.WindowFlags.AlwaysAutoResize or 0) + (imgui.WindowFlags.NoSavedSettings or 0)) then

        imgui.Text("Вы пытаетесь очистить ВЕСЬ УРОВЕНЬ!\nДанное действие невозможно отменить!\n\nВы уверены, что хотите продолжить?")
        imgui.Dummy(imgui.ImVec2(0,2.5))

        if imgui.Button("Да", imgui.ImVec2(imgui.GetWindowSize().x * 0.46, 0)) then
            storage.clearLevel:writeByte(1)
            clearLevelDialog = false
            imgui.CloseCurrentPopup()
        end

        imgui.SameLine()

        if imgui.Button("Нет", imgui.ImVec2(imgui.GetWindowSize().x * 0.46, 0)) then
            clearLevelDialog = false
            imgui.CloseCurrentPopup()
        end

        imgui.EndPopup()
    end

    imgui.SameLine()

    if imgui.Button("OL", imgui.ImVec2(32, 24)) then
        local openFile = fileDialog[2].new()
        openFile.filter = "Supercow Levels (.lev)\0*.lev\0\0"
        if openFile:OpenDialog() then
            storage.parseFormat:writeString("%s")
            local path = ffi.cast("uintptr_t", ffi.new("char[256]", openFile.fileName))
            storage.parseLevelFile(storage.objectPoolAddr, storage.currentStage:readInt(), tonumber(path) - 1)
            storage.parseFormat:writeString("level%.2i.lev")
        end
    end
    tooltip("Открыть уровень из файла")

    imgui.SameLine()

    if imgui.Button("SL", imgui.ImVec2(32, 24)) then
        storage.saveLevel()
    end
    if imgui.BeginPopupContextItem() then
        if imgui.Button("SLF", imgui.ImVec2(32, 24)) then
            local saveFile = fileDialog[1].new()
            saveFile.fileName = "level.lev"
            if saveFile:OpenDialog() then
                storage.readFormat:writeString("%s")
                local path = ffi.cast("uintptr_t", ffi.new("char[256]", saveFile.fileName))
                storage.saveLevelToFile(storage.objectPoolAddr, storage.currentStage:readInt(), tonumber(path) - 1)
                storage.readFormat:writeString("level%.2i.lev")
            end
        end
        tooltip("Сохранить уровень в файл")
        imgui.EndPopup()
    end
    tooltip("Сохранить уровень [F2, Ctrl+S]\nУровень сохраняется по\nуказанному номеру и этапу\nПравый клик для доп. функции")

    imgui.SameLine()

    if imgui.Button("TL", imgui.ImVec2(32, 24)) then
        storage.editorLeaveFullscreen()
        storage.initLevel()
        storage.changeScene(storage.gameSceneAddr)
    end
    tooltip("Тестировать уровень [S, F5, F6]")

    imgui.End()
end
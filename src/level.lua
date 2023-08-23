---@diagnostic disable: undefined-field

local saveLevelToFile = memory.at("E8 ? ? ? ? 8B 15 ? ? ? ? 52 FF 15 ? ? ? ? 5D"):readNearCall():getFunction("char (__thiscall *)(int, int, int)")

local editorLeaveFullscreen = memory.at("E8 ? ? ? ? E8 ? ? ? ? 68 ? ? ? ? 8B 4D ? E8 ? ? ? ? EB"):readNearCall():getFunction("bool (*)()")
local initLevel = memory.at("55 8B EC 83 EC ? E8 ? ? ? ? E8"):getFunction("void (__stdcall *)()")
local changeScene = memory.at("55 8B EC 51 89 4D ? C6 05 ? ? ? ? ? 8B 45"):getFunction("int (__stdcall *)(int)")

local clearLevel = memory.at("A2 ? ? ? ? A1 ? ? ? ? 50 FF 15 ? ? ? ? B8"):add(1):readOffset()
local clearLevelDialog = false

local parseFormat = memory.at("68 ? ? ? ? 8D 8D ? ? ? ? 51 E8 ? ? ? ? 83 C4 ? 68 ? ? ? ? FF 15 ? ? ? ? 8B 55 ? 83 C2 ? 52 68 ? ? ? ? 8D 85 ? ? ? ? 50 E8 ? ? ? ? 83 C4 ? 8D 8D ? ? ? ? 51 FF 15 ? ? ? ? 8D 4D"):add(1):readOffset()
local parseLevelFile = memory.at("E8 ? ? ? ? E8 ? ? ? ? 5D C3 CC 55 8B EC 5D"):readNearCall():getFunction("char (__thiscall *)(int, int, int)")
local currentStageAddr = memory.at("A1 ? ? ? ? 50 B9 ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 5D"):add(1)
local levelName = memory.at("B9 ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 5D"):add(1):readInt()

local readFormat = memory.at("68 ? ? ? ? 8D 8D ? ? ? ? 51 E8 ? ? ? ? 83 C4 ? 68 ? ? ? ? FF 15 ? ? ? ? 8B 55 ? 83 C2 ? 52 68 ? ? ? ? 8D 85 ? ? ? ? 50 E8 ? ? ? ? 83 C4 ? 8D 8D ? ? ? ? 51 FF 15 ? ? ? ? 85 C0"):add(1):readOffset()

--local levelFileName = memory.at("68 ? ? ? ? E8 ? ? ? ? 83 C4 ? 8B 0D ? ? ? ? 51 8B 15"):add(1):readAs("char*")

currentEditorStage = ffi.new("int[1]", 1)
currentEditorLevel = ffi.new("int[1]", 1)

--local test = imgui.GetMainViewport().WorkSize

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetMainViewport().WorkSize.x - 168, 0), imgui.Cond.Once)
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Уровень", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))
    imgui.PushItemWidth(-1)

    --imgui.Text("Текущий путь:")
    --imgui.InputText("###zalupaEbanaya", levelFileName, 64, imgui.InputTextFlags.ReadOnly or 0)

    --imgui.Dummy(imgui.ImVec2(0,2.5))

    imgui.Text("Этап")
    if imgui.InputInt("###stageInputInt", currentEditorStage) then
        currentEditorStageAddr:writeInt(currentEditorStage[0] - 1)
        initEditorLevel()
    end
    tooltip("Переключить номер этапа")

    imgui.Text("Уровень")
    if imgui.InputInt("###levelInputInt", currentEditorLevel) then
        currentEditorLevelAddr:writeInt(currentEditorLevel[0] - 1)
        initEditorLevel()
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
            clearLevel:writeByte(1)
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
        if openFile:OpenDialog() then
            parseFormat:writeString("%s")
            local path = ffi.cast("uintptr_t", ffi.new("char[256]", openFile.fileName))
            parseLevelFile(levelName, currentStageAddr:readInt(), tonumber(path) - 1)
            parseFormat:writeString("level%.2i.lev")
        end
    end
    tooltip("Открыть уровень из файла")

    imgui.SameLine()

    if imgui.Button("SL", imgui.ImVec2(32, 24)) then
        saveLevel()
    end
    if imgui.BeginPopupContextItem() then
        if imgui.Button("SLF", imgui.ImVec2(32, 24)) then
            local saveFile = fileDialog[1].new()
            saveFile.fileName = "level.lev"
            if saveFile:OpenDialog() then
                readFormat:writeString("%s")
                local path = ffi.cast("uintptr_t", ffi.new("char[256]", saveFile.fileName))
                saveLevelToFile(levelName, currentStageAddr:readInt(), tonumber(path) - 1)
                readFormat:writeString("level%.2i.lev")
            end
        end
        tooltip("Сохранить уровень в файл")
        imgui.EndPopup()
    end
    tooltip("Сохранить уровень [F2, Ctrl+S]\nУровень сохраняется по\nуказанному номеру и этапу\nПравый клик для доп. функции")

    imgui.SameLine()

    if imgui.Button("TL", imgui.ImVec2(32, 24)) then
        editorLeaveFullscreen()
        initLevel()
        changeScene(gameScene)
    end
    tooltip("Тестировать уровень [S, F5, F6]")

    imgui.End()
end
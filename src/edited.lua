---@diagnostic disable: undefined-field

local isLevelEdited_closeWindowCall = memory.at("E8 ? ? ? ? 83 F8 ? 74 ? C7 05")
local isLevelEdited_intiLevelCall = memory.at("E8 ? ? ? ? 89 45 ? 83 7D ? ? 75 ? E9")
local endProcess = memory.at("C7 05 ? ? ? ? ? ? ? ? 33 C0 EB"):add(2):readOffset()
local levelEditedBool = objectPool:add(-8)

local openEditedConfirmation = false
local whereCalled = 0

local function levelEditedWindowClose()
    if levelEditedBool:readSBool() then
        openEditedConfirmation = true
        whereCalled = 1
    else
        return 7
    end
    return 2
end
levelEditedWindowCloseCallback = ffi.cast("int (*)()", levelEditedWindowClose)

local function levelEditedLevelInit()
    if levelEditedBool:readSBool() then
        openEditedConfirmation = true
        whereCalled = 2
    else
        return 7
    end
    return 2
end
levelEditedLevelInitCallback = ffi.cast("int (*)()", levelEditedLevelInit)

isLevelEdited_closeWindowCall:writeNearCall(tonumber(ffi.cast("uint32_t", levelEditedWindowCloseCallback)))
isLevelEdited_intiLevelCall:writeNearCall(tonumber(ffi.cast("uint32_t", levelEditedLevelInitCallback)))

local function closeDialog()
    if whereCalled == 1 then
        endProcess:writeInt(1)
    elseif whereCalled == 2 then
        initEditorLevel()
    end
    whereCalled = 0
    openEditedConfirmation = false
    imgui.CloseCurrentPopup()
    modalExecuted = 0
end

return function()
    if openEditedConfirmation and modalExecuted ~= 1 then
        modalExecuted = 2
        imgui.OpenPopup("Внимание!###switchLevelCaution")
    end

    imgui.SetNextWindowPos(imgui:GetMainViewport():GetCenter(), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(275, -1))
    if imgui.BeginPopupModal("Внимание!###switchLevelCaution", nil, (imgui.WindowFlags.AlwaysAutoResize or 0) + (imgui.WindowFlags.NoSavedSettings or 0)) then

        imgui.Text("Уровень был изменён.\nСохранить изменения?")
        imgui.Dummy(imgui.ImVec2(0,2.5))

        if imgui.Button("Да", imgui.ImVec2(imgui.GetWindowSize().x * 0.30, 0)) then
            saveLevel()
            closeDialog()
        end

        imgui.SameLine()

        if imgui.Button("Нет", imgui.ImVec2(imgui.GetWindowSize().x * 0.29, 0)) then
            levelEditedBool:writeByte(0)
            closeDialog()
        end

        imgui.SameLine()

        if imgui.Button("Отмена", imgui.ImVec2(imgui.GetWindowSize().x * 0.29, 0)) then
            local s = currentStageAddr:readInt()
            local l = currentLevelAddr:readInt()
            currentEditorStage[0] = s + 1
            currentEditorLevel[0] = l + 1
            currentEditorStageAddr:writeInt(s)
            currentEditorLevelAddr:writeInt(l)
            whereCalled = 0
            openEditedConfirmation = false
            imgui.CloseCurrentPopup()
            modalExecuted = 0
        end

        imgui.EndPopup()
    end
end
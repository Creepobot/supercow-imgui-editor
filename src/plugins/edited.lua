---@diagnostic disable: undefined-field

local openEditedConfirmation = false
local whereCalled = 0

local function isLevelEdited_closeWindow()
    if storage.levelEdited:readSBool() then
        openEditedConfirmation = true
        whereCalled = 1
    else
        return 7
    end
    return 2
end
isLevelEdited_closeWindow_Callback = ffi.cast("int (*)()", isLevelEdited_closeWindow)

local function isLevelEdited_intiLevel()
    if storage.levelEdited:readSBool() then
        openEditedConfirmation = true
        whereCalled = 2
    else
        return 7
    end
    return 2
end
isLevelEdited_intiLevel_Callback = ffi.cast("int (*)()", isLevelEdited_intiLevel)

storage.isLevelEdited_closeWindowCall:writeNearCall(tonumber(ffi.cast("uint32_t", isLevelEdited_closeWindow_Callback)))
storage.isLevelEdited_intiLevelCall:writeNearCall(tonumber(ffi.cast("uint32_t", isLevelEdited_intiLevel_Callback)))

local function closeDialog()
    if whereCalled == 1 then
        storage.endProcess:writeInt(1)
    elseif whereCalled == 2 then
        storage.initEditorLevel()
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
            storage.saveLevel()
            closeDialog()
        end

        imgui.SameLine()

        if imgui.Button("Нет", imgui.ImVec2(imgui.GetWindowSize().x * 0.29, 0)) then
            storage.levelEdited:writeByte(0)
            closeDialog()
        end

        imgui.SameLine()

        if imgui.Button("Отмена", imgui.ImVec2(imgui.GetWindowSize().x * 0.29, 0)) then
            local s = storage.currentStage:readInt()
            local l = storage.currentLevel:readInt()
            currentEditorStage[0] = s + 1
            currentEditorLevel[0] = l + 1
            storage.currentEditorStage:writeInt(s)
            storage.currentEditorLevel:writeInt(l)
            whereCalled = 0
            openEditedConfirmation = false
            imgui.CloseCurrentPopup()
            modalExecuted = 0
        end

        imgui.EndPopup()
    end
end
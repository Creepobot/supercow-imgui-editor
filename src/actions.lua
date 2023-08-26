---@diagnostic disable: undefined-field

local curEditMode = memory.at("C7 05 ? ? ? ? ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 8B 0D"):add(2):readOffset()
local editModeApply = memory.at("E8 ? ? ? ? E8 ? ? ? ? 8B 0D ? ? ? ? 89 0D"):readNearCall():getFunction("int (*)()")

local invertObjects = memory.at("55 8B EC 83 EC ? 89 4D ? C6 45 ? ? C7 45 ? ? ? ? ? EB ? 8B 45 ? 83 C0 ? 89 45 ? 8B 4D ? 8B 55"):getFunction("int (__thiscall *)(int)")
local deleteObjects = memory.at("55 8B EC 83 EC ? 56 89 4D ? C6 45"):getFunction("int (__thiscall *)(int)")
local cloneObjects = memory.at("55 8B EC 83 EC ? 89 4D ? A1 ? ? ? ? 89 45 ? C6 45"):getFunction("int (__thiscall *)(int)")
local objectToTop = memory.at("55 8B EC 83 EC ? 56 89 4D ? 8B 45 ? 8B 88"):getFunction("void (__thiscall *)(int)")
local objectToDown = memory.at("55 8B EC 83 EC ? 56 89 4D ? C7 45 ? ? ? ? ? C7 45"):getFunction("void (__thiscall *)(int)")

local undo = memory.at("55 8B EC 83 EC ? 89 4D ? 8B 45 ? 8B 4D ? 8B 90"):getFunction("int (__thiscall *)(int)")
local redo = memory.at("E8 ? ? ? ? E9 ? ? ? ? 83 7D ? ? 75 ? C7 05"):readNearCall():getFunction("int (__thiscall *)(int)")

local snapToGrid = memory.at("A2 ? ? ? ? E8 ? ? ? ? E9"):add(1):readOffset()
local debugGrid = memory.at("A2 ? ? ? ? E9 ? ? ? ? 83 7D"):add(1):readOffset()

local objsBool = memory.at("0F B6 15 ? ? ? ? 85 D2 0F 84 ? ? ? ? C7 45"):add(3):readOffset()
local grosSelect = memory.at("0F B6 05 ? ? ? ? 85 C0 75 ? 0F B6 0D ? ? ? ? 85 C9 75 ? E9 ? ? ? ? 8D 4D ? E8 ? ? ? ? 8D 4D"):add(3):readOffset()
local groSelect = memory.at("0F B6 05 ? ? ? ? 85 C0 74 ? 8B 0D ? ? ? ? 3B 4D ? 74 ? EB"):add(3):readOffset()

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Действия", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))

    if imgui.BeginTable("###testTable", 4, (imgui.TableFlags.Borders or 0) + (imgui.TableFlags.NoSavedSettings or 0)) then
        for i = 0, 3, 1 do
            imgui.TableNextColumn()
            if i == 0 then

                if imgui.Selectable_Bool("SM", currentMode:readInt() == i) then
                    curEditMode:writeInt(0)
                    editModeApply()
                end

                if imgui.BeginPopupContextItem() then
                    local dunno2Bool = objsBool:readSBool()
                    if imgui.Checkbox("Объекты", ffi.new("bool[1]", dunno2Bool)) then
                        objsBool:writeByte(dunno2Bool and 0 or 1)
                    end
                    tooltip("Выделение объектов на уровне")

                    local groBool = groSelect:readSBool()
                    local grosBool = grosSelect:readSBool()
                    if imgui.Checkbox("Граунд", ffi.new("bool[1]", groBool)) then
                        if groBool then
                            groSelect:writeByte(0)
                        else
                            groSelect:writeByte(1)
                            if grosBool then
                                grosSelect:writeByte(0)
                            end
                        end
                    end
                    tooltip("Выделение граунда на выбранном слое")

                    if imgui.Checkbox("Граунды", ffi.new("bool[1]", grosBool)) then
                        if grosBool then
                            grosSelect:writeByte(0)
                        else
                            grosSelect:writeByte(1)
                            if groBool then
                                groSelect:writeByte(0)
                            end
                        end
                    end
                    tooltip("Выделение граунда на всех слоях")

                    imgui.EndPopup()
                end
                tooltip("Режим выделения\nПравый клик для настроек")

            elseif i == 1 then

                if imgui.Selectable_Bool("MM", currentMode:readInt() == i) then
                    curEditMode:writeInt(1)
                    editModeApply()
                end
                tooltip("Режим перемещения [Ctrl+ЛКМ]")

            elseif i == 2 then

                if imgui.Selectable_Bool("RM", currentMode:readInt() == i) then
                    curEditMode:writeInt(2)
                    editModeApply()
                end
                tooltip("Режим вращения")

            elseif i == 3 then

                if imgui.Selectable_Bool("ScM", currentMode:readInt() == i) then
                    curEditMode:writeInt(3)
                    editModeApply()
                end
                tooltip("Режим масштаба")

            end
        end
        imgui.EndTable()
    end

    if imgui.Button("IM", imgui.ImVec2(32, 24)) then
        invertObjects(objectPool.addr)
    end
    tooltip("Отзеркалить объект(ы) [I]")

    imgui.SameLine()

    if imgui.Button("DM", imgui.ImVec2(32, 24)) then
        deleteObjects(objectPool.addr)
    end
    tooltip("Удалить объект(ы) [Del]")

    imgui.SameLine()

    if imgui.Button("CM", imgui.ImVec2(32, 24)) then
        cloneObjects(objectPool.addr)
    end
    tooltip("Клонировать объект(ы) [Alt+ЛКМ]")

    imgui.SameLine()

    if imgui.Button("TL", imgui.ImVec2(32, 24)) then
        objectToTop(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на вершину слоя")

    imgui.Indent()
    if imgui.Button("UN", imgui.ImVec2(32, 24)) then
        undo(objectPool.addr)
    end
    tooltip("Отменить прошлое действие [Ctrl+Z]")

    imgui.SameLine()

    if imgui.Button("RE", imgui.ImVec2(32, 24)) then
        redo(objectPool.addr)
    end
    tooltip("Вернуть отменённое действие [Ctrl+Y]")

    imgui.SameLine()

    imgui.Indent(96)
    if imgui.Button("BL", imgui.ImVec2(38, 24)) then
        objectToDown(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на дно слоя")
    imgui.Unindent(96)
    imgui.Unindent()

    imgui.Dummy(imgui.ImVec2(0,2.5))



    local snapToBool = snapToGrid:readByte() ~= 0
    if imgui.Checkbox("STG", ffi.new("bool[1]", snapToBool)) then
        snapToGrid:writeByte(snapToBool and 0 or 1)
    end
    tooltip("Snap To Grid\nПривязка объектов к условной\nсетке во время перемещения [Ctrl+G]")

    imgui.SameLine()
    imgui.Indent(85)

    local debugGridBool = debugGrid:readByte() ~= 0
    if imgui.Checkbox("SGW", ffi.new("bool[1]", debugGridBool)) then
        debugGrid:writeByte(debugGridBool and 0 or 1)
    end
    tooltip("Show Grid View\nВключить отображение сетки [G]")

    mainBlockSize = mainBlockSize + imgui.GetWindowHeight()
    imgui.End()
end
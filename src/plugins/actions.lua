---@diagnostic disable: undefined-field

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Действия", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))

    if imgui.BeginTable("###testTable", 4, (imgui.TableFlags.Borders or 0) + (imgui.TableFlags.NoSavedSettings or 0)) then
        for i = 0, 3, 1 do
            imgui.TableNextColumn()
            if i == 0 then

                if imgui.Selectable_Bool("SM", storage.currentMode:readInt() == i) then
                    storage.currentMode:writeInt(0)
                    storage.currentModeApply()
                end

                if imgui.BeginPopupContextItem() then
                    local dunno2Bool = storage.objsSelect:readSBool()
                    if imgui.Checkbox("Объекты", ffi.new("bool[1]", dunno2Bool)) then
                        storage.objsSelect:writeByte(dunno2Bool and 0 or 1)
                    end
                    tooltip("Выделение объектов на уровне")

                    local groBool = storage.groSelect:readSBool()
                    local grosBool = storage.grosSelect:readSBool()

                    if imgui.Checkbox("Граунд", ffi.new("bool[1]", groBool)) then
                        if groBool then
                            storage.groSelect:writeByte(0)
                        else
                            storage.groSelect:writeByte(1)
                            if grosBool then
                                storage.grosSelect:writeByte(0)
                            end
                        end
                    end
                    tooltip("Выделение граунда на выбранном слое")

                    if imgui.Checkbox("Граунды", ffi.new("bool[1]", grosBool)) then
                        if grosBool then
                            storage.grosSelect:writeByte(0)
                        else
                            storage.grosSelect:writeByte(1)
                            if groBool then
                                storage.groSelect:writeByte(0)
                            end
                        end
                    end
                    tooltip("Выделение граунда на всех слоях")

                    imgui.EndPopup()
                end
                tooltip("Режим выделения\nПравый клик для настроек")

            elseif i == 1 then

                if imgui.Selectable_Bool("MM", storage.currentMode:readInt() == i) then
                    storage.currentMode:writeInt(1)
                    storage.currentModeApply()
                end
                tooltip("Режим перемещения [Ctrl+ЛКМ]")

            elseif i == 2 then

                if imgui.Selectable_Bool("RM", storage.currentMode:readInt() == i) then
                    storage.currentMode:writeInt(2)
                    storage.currentModeApply()
                end
                tooltip("Режим вращения")

            elseif i == 3 then

                if imgui.Selectable_Bool("ScM", storage.currentMode:readInt() == i) then
                    storage.currentMode:writeInt(3)
                    storage.currentModeApply()
                end
                tooltip("Режим масштаба")

            end
        end
        imgui.EndTable()
    end

    if imgui.Button("IM", imgui.ImVec2(32, 24)) then
        storage.invertObjects(storage.objectPoolAddr)
    end
    tooltip("Отзеркалить объект(ы) [I]")

    imgui.SameLine()

    if imgui.Button("DM", imgui.ImVec2(32, 24)) then
        storage.deleteObjects(storage.objectPoolAddr)
    end
    tooltip("Удалить объект(ы) [Del]")

    imgui.SameLine()

    if imgui.Button("CM", imgui.ImVec2(32, 24)) then
        storage.cloneObjects(storage.objectPoolAddr)
    end
    tooltip("Клонировать объект(ы) [Alt+ЛКМ]")

    imgui.SameLine()

    if imgui.Button("TL", imgui.ImVec2(32, 24)) then
        storage.objectToTop(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на вершину слоя")

    imgui.Indent()
    if imgui.Button("UN", imgui.ImVec2(32, 24)) then
        storage.undo(storage.objectPoolAddr)
    end
    tooltip("Отменить прошлое действие [Ctrl+Z]")

    imgui.SameLine()

    if imgui.Button("RE", imgui.ImVec2(32, 24)) then
        storage.redo(storage.objectPoolAddr)
    end
    tooltip("Вернуть отменённое действие [Ctrl+Y]")

    imgui.SameLine()

    imgui.Indent(96)
    if imgui.Button("BL", imgui.ImVec2(38, 24)) then
        storage.objectToDown(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на дно слоя")
    imgui.Unindent(96)
    imgui.Unindent()

    imgui.Dummy(imgui.ImVec2(0,2.5))

    local snapToBool = storage.snapToGrid:readSBool()
    if imgui.Checkbox("STG", ffi.new("bool[1]", snapToBool)) then
        storage.snapToGrid:writeByte(snapToBool and 0 or 1)
    end
    tooltip("Snap To Grid\nПривязка объектов к условной\nсетке во время перемещения [Ctrl+G]")

    imgui.SameLine()
    imgui.Indent(85)

    local debugGridBool = storage.debugGrid:readSBool()
    if imgui.Checkbox("SGW", ffi.new("bool[1]", debugGridBool)) then
        storage.debugGrid:writeByte(debugGridBool and 0 or 1)
    end
    tooltip("Show Grid View\nВключить отображение сетки [G]")

    mainBlockSize = mainBlockSize + imgui.GetWindowHeight()
    imgui.End()
end
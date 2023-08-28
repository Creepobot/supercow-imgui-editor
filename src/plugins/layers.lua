---@diagnostic disable: undefined-field

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Слои", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))

    if imgui.RadioButton_IntPtr("1##layer", storage.layerIntPtr, 0) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на первый слой [Ctrl+1]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("2##layer", storage.layerIntPtr, 1) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на второй слой [Ctrl+2]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("3##layer", storage.layerIntPtr, 2) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на третий слой [Ctrl+3]")

    imgui.Unindent(56)
    imgui.Unindent(56)

    if imgui.RadioButton_IntPtr("4##layer", storage.layerIntPtr, 3) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на четвёртый слой [Ctrl+4]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("5##layer", storage.layerIntPtr, 4) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на пятый слой [Ctrl+5]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("6##layer", storage.layerIntPtr, 5) then
        storage.selectedToLayer(storage.objectPoolAddr)
    end
    tooltip("Переместить объект(ы) на шестой слой [Ctrl+6]")

    imgui.Unindent(56)
    imgui.Unindent(56)

    mainBlockSize = mainBlockSize + imgui.GetWindowHeight()
    imgui.End()
end
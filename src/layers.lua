local layerInt = memory.at("3B 05 ? ? ? ? 74 ? 8B 4D"):add(2):readAs("int*")

local selectedToLayer = memory.at("E8 ? ? ? ? 5D C3 CC CC CC CC CC CC CC CC CC CC CC CC 55 8B EC 6A"):readNearCall():getFunction("void (__thiscall *)(int)")

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, -1))
    imgui.Begin("Слои", nil, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoResize or 0))

    if imgui.RadioButton_IntPtr("1##layer", layerInt, 0) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на первый слой [Ctrl+1]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("2##layer", layerInt, 1) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на второй слой [Ctrl+2]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("3##layer", layerInt, 2) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на третий слой [Ctrl+3]")

    imgui.Unindent(56)
    imgui.Unindent(56)

    if imgui.RadioButton_IntPtr("4##layer", layerInt, 3) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на четвёртый слой [Ctrl+4]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("5##layer", layerInt, 4) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на пятый слой [Ctrl+5]")

    imgui.SameLine()
    imgui.Indent(56)

    if imgui.RadioButton_IntPtr("6##layer", layerInt, 5) then
        selectedToLayer(objectPool.addr)
    end
    tooltip("Переместить объект(ы) на шестой слой [Ctrl+6]")

    imgui.Unindent(56)
    imgui.Unindent(56)

    mainBlockSize = mainBlockSize + imgui.GetWindowHeight()
    imgui.End()
end
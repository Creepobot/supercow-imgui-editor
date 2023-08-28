---@diagnostic disable: undefined-field

-- Зануляет логику, связанную с окном экстрапараметров. Просто чтобы игра себе мозги не ебала
memory.at("E8 ? ? ? ? C6 05 ? ? ? ? ? D9 05"):add(-11):writeNop(23)

local callOnce = true
local objAddr
local header
local extraparam

return function()
    if storage.renderExtraparamsDialog:readSBool() and modalExecuted ~= 2 then
        if callOnce then
            callOnce = false

            local obj = storage.getSelectedObject(storage.objectPoolAddr)
            if obj == 0 then
                storage.renderExtraparamsDialog:writeByte(0)
                callOnce = true
                goto endhere
            end

            objAddr = memory.at(obj)
            local extraparamAddr = objAddr:add(0xF4):readInt()
            extraparam = ffi.new("char[512]", extraparamAddr == 0 and "" or objAddr:add(0xF4):readOffset():readString())
            header = string.format("Параметры для %s", objAddr:add(4):readString(32))
        end

        modalExecuted = 1
        imgui.OpenPopup(header)

        imgui.SetNextWindowPos(imgui.GetIO().MousePos, imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
        if imgui.BeginPopupModal(header, nil, (imgui.WindowFlags.AlwaysAutoResize or 0) + (imgui.WindowFlags.NoSavedSettings or 0)) then

            imgui.InputText("###extraparamtextbox", extraparam, 512)
            tooltip("Ввод экстрапараметров\nдля выделенного объекта")

            if imgui.Button("ОК", imgui.ImVec2(imgui.GetWindowSize().x * 0.46, 0)) then
                storage.setExtraparams(objAddr.addr, extraparam)
                storage.renderExtraparamsDialog:writeByte(0)
                callOnce = true
                imgui.CloseCurrentPopup()
                modalExecuted = 0
            end

            imgui.SameLine()

            if imgui.Button("Отмена", imgui.ImVec2(imgui.GetWindowSize().x * 0.46, 0)) then
                storage.renderExtraparamsDialog:writeByte(0)
                callOnce = true
                imgui.CloseCurrentPopup()
                modalExecuted = 0
            end

            imgui.EndPopup()
        end
        ::endhere::
    end
end
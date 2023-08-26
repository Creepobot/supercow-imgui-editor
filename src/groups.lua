---@diagnostic disable: undefined-field

local groupsCount = memory.at("8B 0D ? ? ? ? 83 E9 ? 51"):add(2):readOffset()
local groupsPool = memory.at("81 C1 ? ? ? ? 51 8D 55 ? 52 E8"):add(2):readOffset()

local cleanGroupsArray = {}

function CleanGroups()
    local gc = groupsCount:readInt() - 1
    for i = 0, gc, 1 do
        local name = groupsPool:add(36 * i):readString()
        local parent = groupsPool:add(36 * i + 32):readInt()
        if parent < 0 then
            cleanGroupsArray[i] = { ["name"] = name }
        else
            if not cleanGroupsArray[parent]["childs"] then
                cleanGroupsArray[parent]["childs"] = {}
            end
            cleanGroupsArray[parent]["childs"][i] = { ["name"] = name }
        end
    end
end

local function renderGroups(tbl)
    for k, v in pairs(tbl) do
        if v["childs"] then
            imgui.Unindent(imgui.GetTreeNodeToLabelSpacing() - 17)
            if imgui.TreeNode(v["name"]) then
                renderGroups(v["childs"])
                imgui.TreePop()
            end
            imgui.Indent(imgui.GetTreeNodeToLabelSpacing() - 17)
        else
            if imgui.Selectable_Bool(v["name"], k == currentGroup:readInt()) then
                currentGroup:writeInt(k)
            end
        end
    end
end

return function()
    imgui.SetNextWindowPos(imgui.ImVec2(mainBlockPos.x, mainBlockPos.y + mainBlockSize))
    imgui.SetNextWindowSize(imgui.ImVec2(168, 200), imgui.Cond.Once)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(168, 100), imgui.ImVec2(168, 500))
    imgui.Begin("Группы", nil, imgui.WindowFlags.NoSavedSettings or 0)
    tooltip("Группы игровых объектов [Alt+{первая буква группы}]")

    imgui.BeginChild("###gameobjsGroupsWindow", imgui.ImVec2(-1, -1), true, (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.AlwaysHorizontalScrollbar or 0))

    renderGroups(cleanGroupsArray)

    imgui.EndChild()

    mainBlockSize = mainBlockSize + imgui.GetWindowHeight()
    imgui.End()
end
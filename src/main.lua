local backup = {}

memory = require("memory").withBackup(backup)
imgui = require("imgui")
ffi = require("ffi")
events = require("events")

ffi.cdef[[
    int ShowWindow(unsigned long hWnd, int nCmdShow);
]]

fileDialog = require("src.libs.fileDialogs")

currentScene = memory.at("81 3D ? ? ? ? ? ? ? ? 0F 95 C0"):add(2):readOffset()
editorScene = memory.at("68 ? ? ? ? 8B 4D ? E8 ? ? ? ? 8B 4D ? 8B 55"):add(1):readInt()
gameScene = memory.at("68 ? ? ? ? B9 ? ? ? ? E8 ? ? ? ? B8 ? ? ? ? E9"):add(1):readInt()

renderExtraparamsDialog = memory.at("C6 05 ? ? ? ? ? E9 ? ? ? ? 83 7D ? ? 75 ? B9"):add(2):readOffset()

objectPool = memory.at("B9 ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 5D"):add(1):readOffset()

local stageLevelPattern = "A1 ? ? ? ? A3 ? ? ? ? 8B 0D ? ? ? ? 89 0D ? ? ? ? 8B 15 ? ? ? ? 83 C2"
currentEditorStageAddr = memory.at(stageLevelPattern):add(1):readOffset()
currentStageAddr = memory.at(stageLevelPattern):add(6):readOffset()
currentEditorLevelAddr = memory.at(stageLevelPattern):add(12):readOffset()
currentLevelAddr = memory.at(stageLevelPattern):add(18):readOffset()

saveLevel = memory.at("55 8B EC D9 05 ? ? ? ? D8 1D ? ? ? ? DF E0 F6 C4 ? 75 ? EB ? E8"):getFunction("void (*)()")
initEditorLevel = memory.at("55 8B EC 83 EC ? A1 ? ? ? ? 89 45 ? E8"):getFunction("int (*)()")

currentGroup = memory.at("A1 ? ? ? ? 6B C0 ? 0F BE 88"):add(1):readOffset()

currentMode = memory.at("C7 05 ? ? ? ? ? ? ? ? A1 ? ? ? ? A3"):add(2):readOffset()

local renderExtraparam = require("src.extraparam")
local renderLevelParameters = require("src.parameters")
local renderActions = require("src.actions")
local renderLayers = require("src.layers")
local renderLevelSelect = require("src.level")
local renderLevelConfirmation = require("src.edited")
local renderObjectGroups = require("src.groups")
local renderObjects = require("src.objects")

local editorInitWindows = memory.at("55 8B EC 81 EC ? ? ? ? 56 57 6A")
local firstEditorWindow = memory.at("A1 ? ? ? ? 50 FF 15 ? ? ? ? 6A ? 8B 0D ? ? ? ? 51 FF 15"):add(1):readOffset()
local secondEditorWindow = memory.at("A1 ? ? ? ? 50 FF 15 ? ? ? ? 6A ? 8B 0D ? ? ? ? 51 FF 15"):add(16):readOffset()

local function hideThatShit(i)
    i = i ~= nil and i or 0
    ffi.C.ShowWindow(firstEditorWindow:readInt(), i)
    ffi.C.ShowWindow(secondEditorWindow:readInt(), i)
end

function tooltip(text)
    if imgui.IsItemHovered((imgui.HoveredFlags.DelayNormal or 0) + (imgui.HoveredFlags.NoSharedDelay)) then
        imgui.BeginTooltip()
            imgui.Text(text)
        imgui.EndTooltip()
    end
end

hideThatShit(0)
CleanGroups()
inEditor = currentScene:readInt() == editorScene
mainBlockPos = imgui.ImVec2(0, 0)
mainBlockSize = 0
modalExecuted = 0

local firstEditorLoadHook
firstEditorLoadHook = editorInitWindows:hook("int(*)()", function()
    inEditor = true
    firstEditorLoadHook.orig()
    hideThatShit(0)
    CleanGroups()
    currentEditorStage[0] = currentEditorStageAddr:readInt() + 1
    currentEditorLevel[0] = currentEditorLevelAddr:readInt() + 1
    return 0
end)

local editorLoadHook
editorLoadHook = memory.at("55 8B EC 51 89 4D ? E8 ? ? ? ? A0"):hook("void (*)()", function()
    inEditor = true
    editorLoadHook.orig()
    hideThatShit(0)
end)

local editorUnloadHook
editorUnloadHook = memory.at("55 8B EC 51 89 4D ? 6A ? A1"):hook("int (*)()", function()
    inEditor = false
    return editorUnloadHook.orig()
end)

function render()
    --imgui.ShowDemoWindow()
    if inEditor then
        renderLevelParameters()
        renderActions()
        renderLayers()
        renderObjectGroups()
        renderObjects()
        renderLevelSelect()
        renderLevelConfirmation()
        renderExtraparam()
    end
end

events.on("_unload", function()
    hideThatShit(1)
    renderExtraparamsDialog:writeByte(0)
    levelEditedWindowCloseCallback:free()
    levelEditedLevelInitCallback:free()
    memory.restoreBackups(backup)
end)
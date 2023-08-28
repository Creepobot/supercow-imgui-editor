local backup = {}

memory = require("memory").withBackup(backup)
imgui = require("imgui")
ffi = require("ffi")
events = require("events")

fileDialog = require("src.libs.fileDialogs")
storage = require("src.storage")

local renderExtraparam = require("src.plugins.extraparam")
local renderLevelParameters = require("src.plugins.parameters")
local renderActions = require("src.plugins.actions")
local renderLayers = require("src.plugins.layers")
local renderLevelSelect = require("src.plugins.level")
local renderLevelConfirmation = require("src.plugins.edited")
local renderObjectGroups = require("src.plugins.groups")
local renderObjects = require("src.plugins.objects")

local function hideThatShit(i)
    i = i ~= nil and i or 0
    ffi.C.ShowWindow(storage.firstEditorWindow:readInt(), i)
    ffi.C.ShowWindow(storage.secondEditorWindow:readInt(), i)
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
inEditor = storage.currentScene:readInt() == storage.editorSceneAddr
mainBlockPos = imgui.ImVec2(0, 0)
mainBlockSize = 0
modalExecuted = 0

local firstEditorLoadHook
firstEditorLoadHook = storage.editorInitWindows:hook("int(*)()", function()
    inEditor = true
    firstEditorLoadHook.orig()
    hideThatShit(0)
    CleanGroups()
    currentEditorStage[0] = storage.currentEditorStage:readInt() + 1
    currentEditorLevel[0] = storage.currentEditorLevel:readInt() + 1
    return 0
end)

local editorLoadHook
editorLoadHook = storage.editorLoad:hook("void (*)()", function()
    inEditor = true
    editorLoadHook.orig()
    hideThatShit(0)
end)

local editorUnloadHook
editorUnloadHook = storage.editorUnload:hook("int (*)()", function()
    inEditor = false
    return editorUnloadHook.orig()
end)

function render()
    imgui.ShowDemoWindow()
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
    storage.renderExtraparamsDialog:writeByte(0)
    isLevelEdited_closeWindow_Callback:free()
    isLevelEdited_intiLevel_Callback:free()
    memory.restoreBackups(backup)
end)
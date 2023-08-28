-- Паттерн на адреса текущего этапа, текущего уровня и текущего этапа в редакторе, текущего уровня в редакторе
local stageLevelPattern = memory.at("A1 ? ? ? ? A3 ? ? ? ? 8B 0D ? ? ? ? 89 0D ? ? ? ? 8B 15 ? ? ? ? 83 C2")
-- Текущий [...] от текущего [...] в редакторе отличается тем, что редакторный сохраняется в настройки и непосредственно нужен для initEditorLevel

-- Память на функцию загрузки уровня на сцену редактора (костыль)
local initEditorLevelAddrLocal = memory.at("55 8B EC 83 EC ? A1 ? ? ? ? 89 45 ? E8")

-- Один адрес на текущие задник, музыку и задание
local currentBackMusicTask = memory.at("A1 ? ? ? ? 69 C0 ? ? ? ? 05 ? ? ? ? 89 45 ? C7 45"):add(1):readOffset()

ffi.cdef[[
    int ShowWindow(int hWnd, int nCmdShow);
]]

return {
    -- Память на адрес текущей сцены (используй readInt)
    currentScene = memory.at("81 3D ? ? ? ? ? ? ? ? 0F 95 C0"):add(2):readOffset(),
    -- Адрес сцены редактора
    editorSceneAddr = memory.at("68 ? ? ? ? 8B 4D ? E8 ? ? ? ? 8B 4D ? 8B 55"):add(1):readInt(),
    -- Адрес игровой сцены
    gameSceneAddr = memory.at("68 ? ? ? ? B9 ? ? ? ? E8 ? ? ? ? B8 ? ? ? ? E9"):add(1):readInt(),

    -- Память на байт, вызывающийся игрой, если нужно открыть диалог экстрапараметров (используй readSBool)
    renderExtraparamsDialog = memory.at("C6 05 ? ? ? ? ? E9 ? ? ? ? 83 7D ? ? 75 ? B9"):add(2):readOffset(),

    -- Память на текущий этап (используй readInt)
    currentStage = stageLevelPattern:add(6):readOffset(),
    -- Память на текущий этап в редакторе (используй readInt)
    currentEditorStage = stageLevelPattern:add(1):readOffset(),
    -- Память на текущий уровень (используй readInt)
    currentLevel = stageLevelPattern:add(18):readOffset(),
    -- Память на текущий уровень в редакторе (используй readInt)
    currentEditorLevel = stageLevelPattern:add(12):readOffset(),

    -- Память на индекс текущей активной группы гейм-объектов (используй readInt)
    currentGroup = memory.at("A1 ? ? ? ? 6B C0 ? 0F BE 88"):add(1):readOffset(),
    -- Память на количество групп гейм-объектов в игре (используй readInt)
    groupsCount = memory.at("8B 0D ? ? ? ? 83 E9 ? 51"):add(2):readOffset(),
    -- Память на пул групп гейм-объектов
    groupsPool = memory.at("81 C1 ? ? ? ? 51 8D 55 ? 52 E8"):add(2):readOffset(),

    -- Память на количество гейм-объектов в игре (используй readInt)
    totalGameobjs = memory.at("3B 0D ? ? ? ? 7D ? 8B 55 ? 6B D2 ? A1"):add(2):readOffset(),
    -- Память на пул гейм-объектов
    gameobjsPool = memory.at("81 C2 ? ? ? ? 52 8B 45 ? 83 C0"):add(2):readOffset(),
    -- Память на индекс текущего активного гейм-объекта (используй readInt)
    currentGameobj = memory.at("A3 ? ? ? ? 83 3D ? ? ? ? ? 74 ? 8B 0D"):add(1):readOffset(),
    -- Память на имя текущего активного гейм-объекта (используй readString)
    -- selectedGameobjName = memory.at("05 ? ? ? ? A3 ? ? ? ? E8"):add(6):readOffset(),

    -- Объекты памяти, использованные в objects.lua.
    -- Мне пиздец лень разбираться зачем, но они нужны
    dunno2_objects = memory.at("83 3D ? ? ? ? ? 74 ? 8B 0D"):add(2):readOffset(),
    dunno3_objects = memory.at("83 3D ? ? ? ? ? 0F 85 ? ? ? ? 83 3D"):add(2):readOffset(),
    dunno1_objects = memory.at("E8 ? ? ? ? 89 45 ? EB ? C7 45 ? ? ? ? ? A1"):readNearCall():getFunction("int (__thiscall *)(int, char)"),
    dunno4_objects = memory.at("55 8B EC 83 EC ? 6A ? 6A ? 68"):getFunction("bool (*)()"),

    -- Память на текущий активный режим редактора (выделение, перемещение и т.д) (используй readInt)
    currentMode = memory.at("C7 05 ? ? ? ? ? ? ? ? A1 ? ? ? ? A3"):add(2):readOffset(),

    -- Память на основное виндовс-окно редатора (используй readInt)
    firstEditorWindow = memory.at("A1 ? ? ? ? 50 FF 15 ? ? ? ? 6A ? 8B 0D ? ? ? ? 51 FF 15"):add(1):readOffset(),
    -- Память на второе виндовс-окно редатора (используй readInt)
    secondEditorWindow = memory.at("A1 ? ? ? ? 50 FF 15 ? ? ? ? 6A ? 8B 0D ? ? ? ? 51 FF 15"):add(16):readOffset(),

    -- Память на байт, активирующий привязку объекта к сетке при перемещении (используй readSBool)
    snapToGrid = memory.at("A2 ? ? ? ? E8 ? ? ? ? E9"):add(1):readOffset(),
    -- Память на байт, активирующий отобращение сетки координат (используй readSBool)
    debugGrid = memory.at("A2 ? ? ? ? E9 ? ? ? ? 83 7D"):add(1):readOffset(),

    -- Память на байт, активирующий выделение объектов в режиме выделения (используй readSBool)
    objsSelect = memory.at("0F B6 15 ? ? ? ? 85 D2 0F 84 ? ? ? ? C7 45"):add(3):readOffset(),
    -- Память на байт, активирующий выделение всех граундов в режиме выделения (используй readSBool)
    grosSelect = memory.at("0F B6 15 ? ? ? ? 85 D2 74 ? C6 05 ? ? ? ? ? 6A"):add(3):readOffset(),
    -- Память на байт, активирующий выделение граундов текущего слоя в режиме выделения (используй readSBool)
    groSelect = memory.at("0F B6 05 ? ? ? ? 85 C0 74 ? 8B 0D ? ? ? ? 3B 4D ? 74 ? EB"):add(3):readOffset(),

    -- Память на байт, отображающий был ли уровень отредактирован (используй readSBool)
    levelEdited = memory.at("0F B6 05 ? ? ? ? 85 C0 75 ? B8"):add(3):readOffset(),

    -- Память на булево, держащее всю игру на себе. Буквально. (используй readBool)
    endProcess = memory.at("C7 05 ? ? ? ? ? ? ? ? 33 C0 EB"):add(2):readOffset(),

    -- Адрес пула объектов на сцене редактора (также адрес имени уровня лол)
    objectPoolAddr = memory.at("B9 ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 5D"):add(1):readInt(),

    -- Индекс текущего слоя, представленный как int*
    layerIntPtr = memory.at("3B 05 ? ? ? ? 74 ? 8B 4D"):add(2):readAs("int*"),

    -- Память на байт, активирующий очистку уровня (используй readSBool)
    clearLevel = memory.at("A2 ? ? ? ? A1 ? ? ? ? 50 FF 15 ? ? ? ? B8"):add(1):readOffset(),

    -- Память на формат-строку для создания пути до уровня в функции parseLevelFile
    parseFormat = memory.at("68 ? ? ? ? 8D 8D ? ? ? ? 51 E8 ? ? ? ? 83 C4 ? 68 ? ? ? ? FF 15 ? ? ? ? 8B 55 ? 83 C2 ? 52 68 ? ? ? ? 8D 85 ? ? ? ? 50 E8 ? ? ? ? 83 C4 ? 8D 8D ? ? ? ? 51 FF 15 ? ? ? ? 8D 4D"):add(1):readOffset(),
    -- Память на формат-строку для создания пути до уровня в функции saveLevelToFile
    readFormat = memory.at("68 ? ? ? ? 8D 8D ? ? ? ? 51 E8 ? ? ? ? 83 C4 ? 68 ? ? ? ? FF 15 ? ? ? ? 8B 55 ? 83 C2 ? 52 68 ? ? ? ? 8D 85 ? ? ? ? 50 E8 ? ? ? ? 83 C4 ? 8D 8D ? ? ? ? 51 FF 15 ? ? ? ? 85 C0"):add(1):readOffset(),

    -- (Типа) путь до текущего уровня, представленный как char*
    -- levelFileName = memory.at("68 ? ? ? ? E8 ? ? ? ? 83 C4 ? 8B 0D ? ? ? ? 51 8B 15"):add(1):readAs("char*"),

    -- Память на количество задников в игре (используй readInt)
    levelBackCount = memory.at("89 0D ? ? ? ? 8B 55 ? 0F BE 02"):add(2):readOffset(),
    -- Память на пул задников
    levelBackPool = memory.at("05 ? ? ? ? 89 45 ? C7 45"):add(1):readOffset(),
    -- Память на пул названий заданий (используй readString)
    levelTaskPool = memory.at("C1 E2 ? 81 C2 ? ? ? ? 52 6A"):add(5):readOffset(),
    -- Память на количество музыки в игре (используй readInt)
    levelMusicCount = memory.at("8B 0D ? ? ? ? 89 04 8D"):add(2):readOffset(),
    -- Память на пул названий музыки (используй readString)
    levelMusicPool = memory.at("81 C1 ? ? ? ? 51 6A ? 68"):add(2):readOffset(),

    currentBack = currentBackMusicTask,
    currentTask = currentBackMusicTask:add(4),
    currentMusic = currentBackMusicTask:add(8),

    -- Память на nearCall функции закрытия игры, вызывающей проверку на наличие изменений в уровне
    isLevelEdited_closeWindowCall = memory.at("E8 ? ? ? ? 83 F8 ? 74 ? C7 05"),
    -- Память на nearCall initEditorLevel функции, вызывающей проверку на наличие изменений в уровне
    isLevelEdited_intiLevelCall = memory.at("E8 ? ? ? ? 89 45 ? 83 7D ? ? 75 ? E9"),

    -- Память на функцию первой загрузки редактора (в неё удобно хукаться)
    editorInitWindows = memory.at("55 8B EC 81 EC ? ? ? ? 56 57 6A"),
    -- Память на функцию загрузки редактора (в неё удобно хукаться)
    editorLoad = memory.at("55 8B EC 51 89 4D ? E8 ? ? ? ? A0"),
    -- Память на функцию выгрузки редактора (в неё удобно хукаться)
    editorUnload = memory.at("55 8B EC 51 89 4D ? 6A ? A1"),

    -- Функция, возвращающая адрес на первый выделенный объект редактора при успехе и 0 при неудаче.
    -- Аргумент - objectPoolAddr
    getSelectedObject = memory.at("E8 ? ? ? ? 85 C0 74 ? 6A ? 68"):readNearCall():getFunction("int (__thiscall *)(int)"),
    -- Функция, задающая экстрапараметр объекту.
    -- Первый аргумент - адрес на объект, второй аргумент - строка экстрапараметра
    setExtraparams = memory.at("E8 ? ? ? ? 6A ? 8B 45 ? 50 FF 15"):readNearCall():getFunction("void (__thiscall *)(int, char*)"),

    -- Функция сохранения уровня (no shit)
    saveLevel = memory.at("55 8B EC D9 05 ? ? ? ? D8 1D ? ? ? ? DF E0 F6 C4 ? 75 ? EB ? E8"):getFunction("void (*)()"),
    -- Память на функцию загрузки уровня на сцену редактора (в неё удобно хукаться)
    initEditorLevelAddr = initEditorLevelAddrLocal,
    -- Функция загрузки уровня на сцену редактора. Возвращает результат проверки на наличие изменений в уровне
    initEditorLevel = initEditorLevelAddrLocal:getFunction("int (*)()"),

    -- Функция, применяющая изменения currentMode
    currentModeApply = memory.at("E8 ? ? ? ? E8 ? ? ? ? 8B 0D ? ? ? ? 89 0D"):readNearCall():getFunction("int (*)()"),

    -- Функция, инвертирующая выделенные объекты. Возвращает 1 при успехе и 0 при неудаче.
    -- Аргумент - objectPoolAddr
    invertObjects = memory.at("55 8B EC 83 EC ? 89 4D ? C6 45 ? ? C7 45 ? ? ? ? ? EB ? 8B 45 ? 83 C0 ? 89 45 ? 8B 4D ? 8B 55"):getFunction("int (__thiscall *)(int)"),
    -- Функция, удаляющая выделенные объекты. Возвращает 1 при успехе и 0 при неудаче.
    -- Аргумент - objectPoolAddr
    deleteObjects = memory.at("55 8B EC 83 EC ? 56 89 4D ? C6 45"):getFunction("int (__thiscall *)(int)"),
    -- Функция, клонирующая выделенные объекты. Возвращает 1 при успехе и 0 при неудаче.
    -- Аргумент - objectPoolAddr
    cloneObjects = memory.at("55 8B EC 83 EC ? 89 4D ? A1 ? ? ? ? 89 45 ? C6 45"):getFunction("int (__thiscall *)(int)"),
    -- Функция, перемещающая выделенные объекты на верх слоя.
    -- Аргумент - objectPoolAddr
    objectToTop = memory.at("55 8B EC 83 EC ? 56 89 4D ? 8B 45 ? 8B 88"):getFunction("void (__thiscall *)(int)"),
    -- Функция, перемещающая выделенные объекты на дно слоя.
    -- Аргумент - objectPoolAddr
    objectToDown = memory.at("55 8B EC 83 EC ? 56 89 4D ? C7 45 ? ? ? ? ? C7 45"):getFunction("void (__thiscall *)(int)"),

    -- Функция, отменяющая действия с объектами
    -- Аргумент - objectPoolAddr
    undo = memory.at("55 8B EC 83 EC ? 89 4D ? 8B 45 ? 8B 4D ? 8B 90"):getFunction("int (__thiscall *)(int)"),
    -- Функция, повторяющая отменённые действия с объектами
    -- Аргумент - objectPoolAddr
    redo = memory.at("E8 ? ? ? ? E9 ? ? ? ? 83 7D ? ? 75 ? C7 05"):readNearCall():getFunction("int (__thiscall *)(int)"),

    -- Функция, перемещающая выделенные объекты на определённый слой
    -- Аргумент - objectPoolAddr
    selectedToLayer = memory.at("E8 ? ? ? ? 5D C3 CC CC CC CC CC CC CC CC CC CC CC CC 55 8B EC 6A"):readNearCall():getFunction("void (__thiscall *)(int)"),

    -- Функция, сохраняющая уровень в файл. Возвращает 1 при успехе и 0 при неудаче.
    -- Первый аргумент - objectPoolAddr, второй аргумент - currentStageAddr, третий - currentLevelAddr
    saveLevelToFile = memory.at("E8 ? ? ? ? 8B 15 ? ? ? ? 52 FF 15 ? ? ? ? 5D"):readNearCall():getFunction("char (__thiscall *)(int, int, int)"),
    -- Функция, читающая уровень из файла. Возвращает 1 при успехе и 0 при неудаче.
    -- Первый аргумент - objectPoolAddr, второй аргумент - currentStageAddr, третий - currentLevelAddr
    parseLevelFile = memory.at("E8 ? ? ? ? E8 ? ? ? ? 5D C3 CC 55 8B EC 5D"):readNearCall():getFunction("char (__thiscall *)(int, int, int)"),

    -- Функция выхода игры из полного экрана или типа того
    editorLeaveFullscreen = memory.at("E8 ? ? ? ? E8 ? ? ? ? 68 ? ? ? ? 8B 4D ? E8 ? ? ? ? EB"):readNearCall():getFunction("bool (*)()"),
    -- Функция инициализации уровня на игровой сцене
    initLevel = memory.at("55 8B EC 83 EC ? E8 ? ? ? ? E8"):getFunction("void (__stdcall *)()"),
    -- Функция переключения сцены. Аргумент - адрес нужной сцены
    changeScene = memory.at("55 8B EC 51 89 4D ? C6 05 ? ? ? ? ? 8B 45"):getFunction("int (__stdcall *)(int)"),

    -- Функция, создающая гейм-объект на сцене. Возвращает адрес на этот самый объект
    -- Аргумент - индекс гейм-объекта
    gameobjCreate = memory.at("E8 ? ? ? ? 83 C4 ? A3 ? ? ? ? 8B 55"):readNearCall():getFunction("int (__cdecl *)(int)")
}
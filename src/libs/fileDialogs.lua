---@diagnostic disable: deprecated

local ffi = require("ffi")
local bit = require("bit")
local com = ffi.load("comdlg32")

ffi.cdef[[
    typedef bool BOOL;
    typedef char CHAR;

    typedef unsigned short WORD; 
    typedef unsigned long DWORD;

    typedef void *PVOID;
    typedef void *LPVOID;
    typedef void *LPOFNHOOKPROC;

    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef HANDLE HINSTANCE;

    typedef const char *LPCSTR;
    typedef const char *LPCTSTR;

    typedef char *LPSTR;
    typedef char *LPTSTR;

    typedef unsigned long LPARAM;

    typedef struct {
        DWORD         lStructSize;
        HWND          hwndOwner;
        HINSTANCE     hInstance;
        LPCTSTR       lpstrFilter;
        LPTSTR        lpstrCustomFilter;
        DWORD         nMaxCustFilter;
        DWORD         nFilterIndex;
        LPTSTR        lpstrFile;
        DWORD         nMaxFile;
        LPTSTR        lpstrFileTitle;
        DWORD         nMaxFileTitle;
        LPCTSTR       lpstrInitialDir;
        LPCTSTR       lpstrTitle;
        DWORD         flags;
        WORD          nFileOffset;
        WORD          nFileExtension;
        LPCTSTR       lpstrDefExt;
        LPARAM        lCustData;
        LPOFNHOOKPROC lpfnHook;
        LPCTSTR       lpTemplateName;

        LPVOID        pvReserved;
        DWORD         dwReserved;
        DWORD         flagsEx;

    }OPENFILENAME;

    BOOL GetSaveFileNameA( OPENFILENAME *lpofn );
    BOOL GetOpenFileNameA( OPENFILENAME *lpofn );
    DWORD GetLastError(void);
]]

FileDialog = {
    title                = "", ---@type string
    filter               = "", ---@type string
    filterIndex          = 0,
    fileName             = "", ---@type string
    initialDirectory     = "", ---@type string
    checkFileExists      = false,
    checkPathExists      = false,
    createPrompt         = false,
    func                 = nil ---@type function
}
FileDialog.__index = FileDialog

function FileDialog:OpenDialog()
    local myFlags = {
        self.checkFileExists and 0x1000 or 0x0,
        self.checkPathExists and 0x800 or 0x0,
        self.overwritePrompt and 0x2 or 0x0,
        self.createPrompt and 0x2000 or 0x0, 0x8
    }
    Ofn = ffi.new("OPENFILENAME")
    ffi.fill(Ofn, ffi.sizeof(Ofn)) --zero fill the structure

    local szFile        = ffi.new("char[260]","\0")
    local hwnd          = ffi.new("HWND",0)

    Ofn.lpstrTitle      = ffi.new("char[260]", self.title)
    Ofn.lStructSize     = ffi.sizeof(Ofn)
    Ofn.hwndOwner       = hwnd
    Ofn.nMaxFile        = ffi.sizeof(szFile)
    Ofn.lpstrFilter     = self.filter
    Ofn.nFilterIndex    = self.filterIndex
    Ofn.lpstrFile       = ffi.new("char[260]", self.fileName)
    Ofn.lpstrInitialDir = ffi.new("char[260]", self.initialDirectory)
    Ofn.flags           = bit.bor(unpack(myFlags))

    if self.func and self.func(Ofn) then
        self.fileName = ffi.string(Ofn.lpstrFile)
        return true
    end
    return false
end

SaveFileDialog = {}
SaveFileDialog.__index = SaveFileDialog
setmetatable(SaveFileDialog, FileDialog)

function SaveFileDialog.new()
    local obj = setmetatable({}, FileDialog)
    obj.func = com.GetSaveFileNameA
    return obj
end

OpenFileDialog = {}
OpenFileDialog.__index = OpenFileDialog
setmetatable(OpenFileDialog, FileDialog)

function OpenFileDialog.new()
    local obj = setmetatable({}, FileDialog)
    obj.func = com.GetOpenFileNameA
    return obj
end

return { SaveFileDialog, OpenFileDialog }
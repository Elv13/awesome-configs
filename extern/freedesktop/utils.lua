-- Grab environment

local io = io
local os = os
local table = table
local type = type
local ipairs = ipairs
local pairs = pairs
local print = print
local config = require("forgotten")

local module = {}

terminal = 'xterm'

module.icon_theme = nil

all_icon_sizes = {
    '128x128',
    '96x96',
    '72x72',
    '64x64',
    '48x48',
    '36x36',
    '32x32',
    '24x24',
    '22x22',
    '16x16'
}
all_icon_types = {
    'apps',
    'actions',
    'devices',
    'places',
    'categories',
    'status',
    'mimetypes'
}
all_icon_paths = { os.getenv("HOME") .. '/.icons/', '/usr/share/icons/' }

icon_sizes = {}

local mime_types = {}

function module.add_base_path(p)
    all_icon_paths[#all_icon_paths+1] = p
end

local icon_theme_paths = {}
function module.add_theme_path(p)
    icon_theme_paths[#icon_theme_paths+1] = p
end

function module.get_lines(...)
    local f = io.popen(...)
    return function () -- iterator
        local data = f:read()
        if data == nil then f:close() end
        return data
    end
end

function module.file_exists(filename)
    local file = io.open(filename, 'r')
    local result = (file ~= nil)
    if result then
        file:close()
    end
--     print (filename)
    return result
end

local cache_paths,cached_bysize,cached_bysize_bycat,other_path=nil,{}

--Avoid making it at startup
local function fill_bycat()
    return {
        apps       = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        actions    = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        devices    = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        places     = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        categories = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        status     = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
        mimetypes  = {s128x128 = {}, s96x96 = {}, s72x72 = {}, s64x64 = {}, s48x48 = {}, s36x36 = {}, s32x32 = {}, s24x24 = {}, s22x22 = {}, s16x16 = {}, },
    }
end

local function gen_paths()
    cached_bysize_bycat = fill_bycat()
    cache_paths = {}
    local icon_path = {}
        local icon_themes = {}
        if module.icon_theme and type(module.icon_theme ) == 'table' then
            icon_themes = module.icon_theme 
        elseif module.icon_theme then
            icon_themes = { module.icon_theme }
        end
        for i=1,#icon_themes do
            for j=1,#all_icon_paths do
                local path = all_icon_paths[j] .. icon_themes[i] .. '/'
                --Do not all wrong path, it will cause expodential file lookup later
                local exec_r = os.execute("ls "..path.."> /dev/null 2> /dev/null")
                if exec_r == 0 or exec_r == true then
                    print("adding")
                    icon_theme_paths[#icon_theme_paths+1] = path
                end
            end
            -- TODO also look in parent icon themes, as in freedesktop.org specification
        end
        icon_theme_paths[#icon_theme_paths+1] = '/usr/share/icons/hicolor/' -- fallback theme cf spec

        local isizes = all_icon_sizes

        for i=1,#icon_theme_paths do
            for j=1,#isizes do
                local s = isizes[j]
                local path = icon_theme_paths[i] ..s
                --Again, make the lookup smaller. the execute is slow, but x1000 unecessary check is slower
                cached_bysize[s] = cached_bysize[s] or {}
                cached_bysize_bycat[s] = cached_bysize_bycat[s] or {}
                local t = cached_bysize[s]
                local exec_r = os.execute("ls "..path.."> /dev/null 2> /dev/null")
                if exec_r == 0 or exec_r == true then --Lua 5.1 and 5.2 have different return types
                    for k=1,#all_icon_types do
                        local type2 = all_icon_types[k]
                        local cp = path .. '/' .. type2 .. '/'
                        icon_path[#icon_path+1] = cp
                        t[#t+1] = cp
                        local ts = cached_bysize_bycat[type2]['s'..s]
                        ts[#ts+1] = cp
                    end
                end
            end
        end
        cache_paths = icon_path

        -- lowest priority fallbacks
        other_path = {'/usr/share/pixmaps/','/usr/share/icons/','/usr/share/app-install/icons/'}
        return icon_path
end

countt =1
local cache = {}
function module.lookup_icon(arg)
    local cached_find = (arg.icon:find('.+%.png') or arg.icon:find('.+%.xpm'))
    if arg.icon:sub(1, 1) == '/' and cached_find then
        -- icons with absolute path and supported (AFAICT) formats
        return arg.icon
    elseif arg.icon:sub(1, 6) == "AWECFG" then
        return arg.icon:gsub("AWECFG", config.iconPath)
    else
        cache_paths = cache_paths or gen_paths()
        local paths = nil
        if arg.category and arg.icon_size then
            paths = cached_bysize_bycat[arg.category]["s"..arg.icon_size]
        else
            paths = cached_bysize[arg.icon_sizes] and cached_bysize[arg.icon_size] or cache_paths or gen_paths()
        end
        for i=1,#paths do
            local directory = paths[i]
            if cached_find and module.file_exists(directory .. arg.icon) then
                return directory .. arg.icon
            elseif not cached_find and module.file_exists(directory .. arg.icon .. '.png') then
                return directory .. arg.icon .. '.png'
            end
        end
        for i=1,#other_path do --Separated to prevent the cost of adding these to all prefiltered paths
            local directory = other_path[i]
            if cached_find and module.file_exists(directory .. arg.icon) then
                return directory .. arg.icon
            elseif not cached_find and module.file_exists(directory .. arg.icon .. '.png') then
                return directory .. arg.icon .. '.png'
            elseif not cached_find and module.file_exists(directory .. arg.icon .. '.xpm') then
                return directory .. arg.icon .. '.xpm'
            end
        end
    end
end

function module.lookup_file_icon(arg)
    load_mime_types()

    local extension = arg.filename:match('%a+$')
    local mime = mime_types[extension] or ''
    local mime_family = mime:match('^%a+') or ''

    -- possible icons in a typical gnome theme (i.e. Tango icons)
    local possible_filenames = {
        mime,
        'gnome-mime-' .. mime,
        mime_family,
        'gnome-mime-' .. mime_family,
        extension
    }

    for i, filename in ipairs(possible_filenames) do
        local icon = module.lookup_icon({icon = filename, icon_sizes = (arg.icon_sizes or all_icon_sizes)})
        if icon then
            return icon
        end
    end

    -- If we don't find ad icon, then pretend is a plain text file
    return module.lookup_icon({ icon = 'txt', icon_sizes = arg.icon_sizes or all_icon_sizes })
end

--- Load system MIME types
-- @return A table with file extension <--> MIME type mapping
function module.load_mime_types()
    if #mime_types == 0 then
        for line in io.lines('/etc/mime.types') do
            if not line:find('^#') then
                local parsed = {}
                for w in line:gmatch('[^%s]+') do
                    table.insert(parsed, w)
                end
                if #parsed > 1 then 
                    for i = 2, #parsed do
                        mime_types[parsed[i]] = parsed[1]:gsub('/', '-')
                    end
                end
            end
        end
    end
end

--- Parse a .desktop file
-- @param file The .desktop file
-- @param requested_icon_sizes A list of icon sizes (optional). If this list is given, it will be used as a priority list for icon sizes when looking up for icons. If you want large icons, for example, you can put '128x128' as the first item in the list.
-- @return A table with file entries.
function module.parse_desktop_file(arg)
    local program = { show = true, file = arg.file }
    for line in io.lines(arg.file) do
        for key, value in line:gmatch("(%w+)=(.+)") do
            program[key] = value
        end
    end

    -- Don't show the program if NoDisplay is true
    -- Only show the program if there is not OnlyShowIn attribute
    -- or if it's equal to 'awesome'
    if program.NoDisplay == "true" or program.OnlyShowIn ~= nil and program.OnlyShowIn ~= "awesome" then
        program.show = false
    end

    -- Look up for a icon.
    if program.Icon then
        program.icon_path = module.lookup_icon({ icon = program.Icon, icon_sizes = (arg.icon_sizes or all_icon_sizes),icon_size=arg.size,category=arg.category})
        if program.icon_path ~= nil and not module.file_exists(program.icon_path) then
           program.icon_path = nil
        end
    end

    -- Split categories into a table.
    if program.Categories then
        program.categories = {}
        for category in program.Categories:gmatch('[^;]+') do
            table.insert(program.categories, category)
        end
    end

    if program.Exec then
        local cmdline = program.Exec:gsub('%%c', program.Name)
        cmdline = cmdline:gsub('%%[fmuFMU]', '')
        cmdline = cmdline:gsub('%%k', program.file)
        if program.icon_path then
            cmdline = cmdline:gsub('%%i', '--icon ' .. program.icon_path)
        else
            cmdline = cmdline:gsub('%%i', '')
        end
        if program.Terminal == "true" then
            cmdline = terminal .. ' -e ' .. cmdline
        end
        program.cmdline = cmdline
    end

    return program
end

--- Parse a directory with .desktop files
-- @param dir The directory.
-- @param icons_size, The icons sizes, optional.
-- @return A table with all .desktop entries.
function module.parse_desktop_files(arg)
    local programs = {}
    local files = module.get_lines('find '.. arg.dir ..' -name "*.desktop" 2>/dev/null')
    for file in files do
        arg.file = file
        table.insert(programs, module.parse_desktop_file(arg))
    end
    return programs
end

--- Parse a directory files and subdirs
-- @param dir The directory.
-- @param icons_size, The icons sizes, optional.
-- @return A table with all .desktop entries.
function module.parse_dirs_and_files(arg)
    local files = {}
    local paths = module.get_lines('find '..arg.dir..' -maxdepth 1 -type d')
    for path in paths do
        if path:match("[^/]+$") then
            local file = {}
            file.filename = path:match("[^/]+$")
            file.path = path
            file.show = true
            file.icon = module.lookup_icon({ icon = "folder", icon_sizes = (arg.icon_sizes or all_icon_sizes) })
            table.insert(files, file)
        end
    end
    local paths = module.get_lines('find '..arg.dir..' -maxdepth 1 -type f')
    for path in paths do
        if not path:find("%.desktop$") then
            local file = {}
            file.filename = path:match("[^/]+$")
            file.path = path
            file.show = true
            file.icon = module.lookup_file_icon({ filename = file.filename, icon_sizes = (arg.icon_sizes or all_icon_sizes) })
            table.insert(files, file)
        end
    end
    return files
end

return module
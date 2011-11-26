local setmetatable = setmetatable
local ipairs       = ipairs
local print        = print
local table        = table
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )
local common       = require( "ultiLayout.common" )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.grid")

function new(cg,orientation)
   local data = {}
   data.ratio = {}
   local nb =0
   local nb_rows = 0
   local isSplit = false
   local rows = {}
   
   local function make_room(percentage) --Between 0 and 1
       if nb >= 1 then
           isSplit = true
           cg:childs()[1].width(cg.width() * 0.75)
       end
   end
   
   function data:update()
        if mainCg then
            mainCg:geometry(mainGeo)
            mainCg:repaint({width  = cg.width()*0.65, height = cg.height(), x = cg.x(), y = cg.y()})
        end
        if subCg then
            subCg:geometry({width  = cg.width()*0.35, height = cg.height(), x = cg.x()+(cg.width()*0.65), y = cg.y()})
            subCg:repaint()
        end
   end
   
   function data:gen_vertex(vertex_list)
       local prev = nil
       local nb   = 0
       for k,v in ipairs(rows) do
            if prev and nb ~= #rows then
                local aVertex = common.create_vertex({x=cg.x(),y=cg.y(),orientation=orientation,length=(orientation == "horizontal") and cg.width() or cg.height()})
                aVertex:attach(prev)
                aVertex:attach(v)
                table.insert(vertex_list,aVertex)
            end
            v:get_vertex(vertex_list)
            prev = v
            nb = nb+1
       end
       return vertex_list
   end
   
   function data:add_child(new_cg, orientation)
        nb = nb + 1
        local function add_col()
            local aCol = clientGroup()
            if orientation == "horizontal" then
                aCol:set_layout(common.get_layout_list()["horizontal"](aCol))
            else
                aCol:set_layout(common.get_layout_list()["vertical"](aCol))
            end
            table.insert(rows,aCol)
            nb_rows = nb_rows + 1
            return aCol
        end
        if nb == 1 then
            add_col():attach(new_cg)
        else
            local per_col = #(rows[1])
            local done = false
            for k,v in ipairs(rows) do
                if #v ~= per_col then
                    v:attach(new_cg)
                    done = true
                    break
                end
            end
            if not done then
                add_col():attach(new_cg)
            end
        end
        local percent = 1 / nb
        data.ratio[new_cg] = percent
   end
   return data
end

local function horizontalgrid(cg)
    local tile = new(cg,"horizontal")
    local data={}
    function data:make_room(percentage) tile:make_room(percentage) end
    function data:add_child(new_cg) tile:add_child(new_cg,"horizontal") end
    function data:update() tile:update() end
end
common.add_new_layout("horizontalgrid",horizontalgrid)

local function horizontalgrid(cg)
    local tile = new(cg,"vertical")
    local data={}
    function data:make_room(percentage) tile:make_room(percentage) end
    function data:add_child(new_cg) tile:add_child(new_cg,"vertical") end
    function data:update() tile:update() end
end
common.add_new_layout("verticalgrid",verticalgrid)

setmetatable(_M, { __call = function(_, ...) return new(...) end })
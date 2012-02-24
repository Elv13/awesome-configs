local print        = print
local pairs        = pairs
local table        = table
local common       = require( "ultiLayout.common"      )
local clientGroup  = require( "ultiLayout.clientGroup" )
module("ultiLayout.tile")

local function create_cg(parent, layout, tile_layout)
    local tile = clientGroup()
    tile:set_layout(common.get_layout_list()[tile_layout](tile))
    layout:add_child(tile)
    parent:attach(tile)
    return tile
end

local function tile(cg,main_layout_name,sub_layout_name,right)
    local layout = common.get_layout_list()[main_layout_name](cg)
    local main_tile,second_tile
    if right == true then
        main_tile, second_tile = create_cg(cg,layout,sub_layout_name),create_cg(cg,layout,sub_layout_name)
    else
        second_tile, main_tile = create_cg(cg,layout,sub_layout_name),create_cg(cg,layout,sub_layout_name)
    end
    
    layout.add_child = function(self,new_cg)
        if new_cg == main_tile or new_cg == second_tile then return end
        ((#main_tile:childs() < 1) and main_tile or second_tile):attach(new_cg)
    end 
    
    return layout
end

local function grid(cg,main_layout_name,sub_layout_name)
    local layout = common.get_layout_list()[main_layout_name](cg)
    layout.add_child_orig = layout.add_child
    local function new_add_child(self,new_cg)
        local lowest  = nil
        for k,v in pairs(cg:childs()) do
            lowest = (lowest ~= nil and (#lowest:childs() <= #v:childs())) and lowest or v
        end
        if lowest and #lowest:childs() < #cg:childs() then
            lowest:attach(new_cg)
        else
            layout.add_child = layout.add_child_orig
            local row = create_cg(cg,layout,sub_layout_name)
            layout.add_child = new_add_child
            row:attach(new_cg)
        end
    end
    layout.add_child = new_add_child
    
    return layout
end

common.add_new_layout("righttile"   , function(cg) return tile(cg,"vertical"   , "horizontal" ,true  ) end)
common.add_new_layout("lefttile"    , function(cg) return tile(cg,"vertical"   , "horizontal" ,false ) end)
common.add_new_layout("topttile"    , function(cg) return tile(cg,"horizontal" , "vertical"   ,true  ) end)
common.add_new_layout("bottomttile" , function(cg) return tile(cg,"horizontal" , "vertical"   ,false ) end)
common.add_new_layout("topgrid"     , function(cg) return grid(cg,"horizontal" , "vertical"          ) end)
common.add_new_layout("leftgrid"    , function(cg) return grid(cg,"vertical"   , "horizontal"        ) end)
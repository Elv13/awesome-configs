local print        = print
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

function tile(cg,main_layout_name,sub_layout_name,right)
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

common.add_new_layout("righttile"   , function(cg) return tile(cg,"vertical"   , "horizontal" ,true  ) end)
common.add_new_layout("lefttile"    , function(cg) return tile(cg,"vertical"   , "horizontal" ,false ) end)
common.add_new_layout("topttile"    , function(cg) return tile(cg,"horizontal" , "vertical"   ,true  ) end)
common.add_new_layout("bottomttile" , function(cg) return tile(cg,"horizontal" , "vertical"   ,false ) end)
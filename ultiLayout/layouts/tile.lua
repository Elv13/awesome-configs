local print        = print
local pairs        = pairs
local table        = table
local common       = require( "ultiLayout.common"      )
local clientGroup  = require( "ultiLayout.clientGroup" )
module("ultiLayout.layouts.tile")

local function create_cg(parent, layout, tile_layout,percent)
    local tile = clientGroup()
    tile.default_percent = percent
    tile.keep = true
    tile:set_layout(common.get_layout_list()[tile_layout])
    layout:add_child(tile)
    parent:attach(tile)
    return tile
end

local function tile(cg,main_l_name,sub_l_name,right)
    local layout = common.get_layout_list()[main_l_name](cg)
    local m_tile,s_tile
    if right == true then
        m_tile, s_tile = create_cg(cg,layout,sub_l_name,65),create_cg(cg,layout,sub_l_name,35)
    else
        s_tile, m_tile = create_cg(cg,layout,sub_l_name,65),create_cg(cg,layout,sub_l_name,35)
    end
    layout.update_orig = layout.update
    function layout:update()
        if m_tile and #m_tile:childs() == 0 and s_tile and #s_tile:childs() > 0 then
            clientGroup.lock()
            m_tile:attach(s_tile:childs()[1])
            clientGroup.unlock()
            return
        end
        layout:update_orig()
    end
    layout.add_child_orig = layout.add_child
    layout.add_child = function(self,new_cg)
        if new_cg == m_tile or new_cg == s_tile then return end
        ((#m_tile:childs() < 1) and m_tile or s_tile):attach(common.wrap_stack(new_cg))
    end 
    
    return layout
end

local function highres(cg)
  local main_layout = common.get_layout_list().horizontal(cg)
  local cg_top,cg_bottom = create_cg(cg,main_layout,"righttile",65),create_cg(cg,main_layout,"horizontal",35)
  --cg:attach()
  main_layout.add_child_orig = main_layout.add_child
    print("\n\nHERE2",#cg_top:all_visible_childs(),#cg_bottom:childs(),#cg_top:all_childs())
  function main_layout:add_child(new_cg)
    print("\n\nHERE",#cg_top:all_visible_childs(),#cg_bottom:childs(),#cg_top:all_childs())
    clientGroup.lock()
    if (#cg_top:all_visible_childs() < 1) then
      print("here3")
      cg_top:attach(new_cg)
    elseif (#cg_bottom:childs() < 1) then
      print("here4")
      cg_bottom:attach(new_cg)
    elseif #cg_bottom:childs() == 1 and #cg_top:childs() > 1 then
      print("here5")
      cg_bottom:attach(new_cg)
    else
      print("here6")
      cg_top:attach(new_cg)
    end
    clientGroup.unlock()
  end
  return main_layout
end

local function grid(cg,main_l_name,sub_l_name)
    local layout = common.get_layout_list()[main_l_name](cg)
    layout.add_child_orig = layout.add_child
    local function new_add_child(self,new_cg)
        local lowest  = nil
        for k,v in pairs(cg:childs()) do
            lowest = (lowest ~= nil and (#lowest:childs() <= #v:childs())) and lowest or v
        end
        if lowest and #lowest:childs() < #cg:childs() then
            lowest:attach(common.wrap_stack(new_cg))
        else
            layout.add_child = layout.add_child_orig
            local row = create_cg(cg,layout,sub_l_name)
            layout.add_child = new_add_child
            row:attach(common.wrap_stack(new_cg))
        end
    end
    layout.add_child = new_add_child
    
    return layout
end

local function spiral(cg,main_l_name)
    local layout = common.get_layout_list()[(main_l_name == "horizontal") and "vertical" or "horizontal"](cg)
    local current_orientation = main_l_name
    local current_level = create_cg(cg,layout,main_l_name)
    
    layout.add_child = function(self,new_cg)
        if #current_level:childs() >= 1 then
            current_orientation = (current_orientation == "horizontal") and "vertical" or "horizontal"
            local tmpCg = clientGroup()
            tmpCg:set_layout(common.get_layout_list()[current_orientation])
            current_level:attach(tmpCg)
            current_level = tmpCg
        end
        current_level:attach(new_cg)
    end
    return layout
end

common.add_new_layout("righttile"       , function(cg) return tile    ( cg, "vertical"   , "horizontal" ,true  ) end)
common.add_new_layout("lefttile"        , function(cg) return tile    ( cg, "vertical"   , "horizontal" ,false ) end)
common.add_new_layout("toptile"         , function(cg) return tile    ( cg, "horizontal" , "vertical"   ,true  ) end)
common.add_new_layout("bottomtile"      , function(cg) return tile    ( cg, "horizontal" , "vertical"   ,false ) end)
common.add_new_layout("highres"         , function(cg) return highres ( cg                                     ) end)
common.add_new_layout("verticalgrid"    , function(cg) return grid    ( cg, "horizontal" , "vertical"          ) end)
common.add_new_layout("horizontalgrid"  , function(cg) return grid    ( cg, "vertical"   , "horizontal"        ) end)
common.add_new_layout("horizontalspiral", function(cg) return spiral  ( cg, "horizontal"                       ) end)
common.add_new_layout("verticalspiral"  , function(cg) return spiral  ( cg, "vertical"                         ) end)
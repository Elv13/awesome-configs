local theme,path = ...
local blind      = require( "blind"          )

theme.layout = blind {
    fairh           = path .."Icon/layouts/fairh.png",
    fairv           = path .."Icon/layouts/fairv.png",
    floating        = path .."Icon/layouts/floating.png",
    magnifier       = path .."Icon/layouts/magnifier.png",
    max             = path .."Icon/layouts/max.png",
    fullscreen      = path .."Icon/layouts/fullscreen.png",
    tilebottom      = path .."Icon/layouts/tilebottom.png",
    tileleft        = path .."Icon/layouts/tileleft.png",
    tile            = path .."Icon/layouts/tile.png",
    tiletop         = path .."Icon/layouts/tiletop.png",
    spiral          = path .."Icon/layouts/spiral.png",
    spiraldwindle   = path .."Icon/layouts/spiral_d.png",

    small = blind {
        fairh         = path .."Icon/layouts_small/fairh.png",
        fairv         = path .."Icon/layouts_small/fairv.png",
        floating      = path .."Icon/layouts_small/floating.png",
        magnifier     = path .."Icon/layouts_small/magnifier.png",
        max           = path .."Icon/layouts_small/max.png",
        fullscreen    = path .."Icon/layouts_small/fullscreen.png",
        tilebottom    = path .."Icon/layouts_small/tilebottom.png",
        tileleft      = path .."Icon/layouts_small/tileleft.png",
        tile          = path .."Icon/layouts_small/tile.png",
        tiletop       = path .."Icon/layouts_small/tiletop.png",
        spiral        = path .."Icon/layouts_small/spiral.png",
        spiraldwindle = path .."Icon/layouts_small/spiral_d.png",
    }
}
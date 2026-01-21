
// Draw with correct facing direction
var _xscale = flipSprite ? fxDirection : 1;

draw_sprite_ext(
    sprite_index,
    image_index,
    x, y,
    _xscale, 1,
    0,
    c_white,
    image_alpha
);
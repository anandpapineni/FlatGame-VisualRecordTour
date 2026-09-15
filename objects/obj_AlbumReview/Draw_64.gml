// Panel geometry now lives on the instance (see Create) so other objects
// can line up against it. Recompute each frame to survive a resize.
update_geometry();

var x1 = box_x1;
var y1 = box_y1;
var x2 = box_x2;
var y2 = box_y2;

// 4. Draw the background box (Black rectangle with a white border)
draw_sprite_stretched(spr_AlbumReview, 0, x1, y1, x2 - x1, y2 - y1);

// 5. Draw the text inside the box
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Calculate max text width before it wraps to the next line
var max_width = (x2 - x1) - (padding * 2);


// Copy from character 1 up to the current floor value of char_current
var _text_to_draw = string_copy(string_hash_to_newline(AlbumDescReview), 1, floor(char_current));
// draw_text_ext handles auto-wrapping based on the max_width
draw_text_ext(x1 + padding, y1 + padding, _text_to_draw, -1, max_width);

// 1. Get the current dimensions of the GUI layer
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// 2. Define the dimensions of the text box
var box_margin = 20;               // Distance from the screen edges
var box_height = 120;              // How tall the text box is
var padding = 15;                  // Distance from the text to the box border

// 3. Calculate box corners
var x1 = box_margin;
var y1 = gui_h - box_height - box_margin;
var x2 = gui_w - box_margin;
var y2 = gui_h - box_margin;

// 4. Draw the background box (Black rectangle with a white border)
draw_sprite_stretched(spr_AlbumReview, 0, x1, y1, x2 - x1, y2 - y1);  // True means outline

// 5. Draw the text inside the box
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Calculate max text width before it wraps to the next line
var max_width = (x2 - x1) - (padding * 2);


// Copy from character 1 up to the current floor value of char_current
var _text_to_draw = string_copy(AlbumDescReview, 1, floor(char_current));
// draw_text_ext handles auto-wrapping based on the max_width
draw_text_ext(x1 + padding, y1 + padding, _text_to_draw, -1, max_width);

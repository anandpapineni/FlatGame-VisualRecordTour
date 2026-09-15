AlbumDescReview = "Oops, set your variables.";
boxWidth = sprite_get_width(spr_AlbumDesc);
stringHeight = string_height(AlbumDescReview)

// Typewriting Vars
char_current = 0;
// How fast the text reveals (e.g., 0.5 characters per frame)
char_speed = 1.6;


// ---------------------------------------------------------------------
//  Panel geometry.
//
//  These were local vars inside Draw GUI, which meant nothing outside
//  this object could see where the panel actually is. Hoisted to
//  instance variables so obj_AlbumQR can align to the real box rather
//  than carrying its own copy of the same numbers — change box_height
//  here and the QR follows it.
// ---------------------------------------------------------------------

box_margin = 20;			// distance from the screen edges
box_height = 150;			// how tall the text box is
padding    = 15;			// distance from the text to the box border

box_x1 = 0;
box_y1 = 0;
box_x2 = 0;
box_y2 = 0;

/// @func update_geometry()
/// @desc Recomputed rather than cached once, so the panel survives a
///       window resize or a GUI layer resolution change.
update_geometry = function() {
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();

	box_x1 = box_margin;
	box_y1 = _gui_h - box_height - box_margin;
	box_x2 = _gui_w - box_margin;
	box_y2 = _gui_h - box_margin;
};

update_geometry();

/// obj_AlbumQR — Draw GUI
///
/// Draw GUI rather than Draw, to match obj_AlbumReview. Coordinates are
/// GUI-space and independent of the camera.

if (owner == noone || !instance_exists(owner)) exit;
if (alpha <= 0.01) exit;


// ---- sit on top of the review panel, using ITS numbers ----
var _x2, _y1;

if (review != noone && instance_exists(review)) {
	review.update_geometry();
	_x2 = review.box_x2;
	_y1 = review.box_y1;
} else {
	// Fallback if the panel isn't there — mirrors the defaults in
	// obj_AlbumReview so the code still lands somewhere sensible.
	_x2 = display_get_gui_width() - 20;
	_y1 = display_get_gui_height() - 150 - 20;
}

// Right-aligned to the panel's right edge, resting just above it.
//   left-aligned instead:  review.box_x1
//   centred instead:       (review.box_x1 + review.box_x2 - qr_size) / 2
qr_x = _x2 - qr_size;
qr_y = _y1 - qr_size - gap;


if (owner.qr_ready && sprite_exists(owner.qr_sprite)) {

	// The one QR-specific thing in all of this: bilinear filtering smears
	// the module edges into grey and a scanner's threshold pass stops
	// finding them. Off before drawing, restored after.
	var _prev = gpu_get_texfilter();
	gpu_set_texfilter(false);

	var _scale = qr_size / sprite_get_width(owner.qr_sprite);
	draw_sprite_ext(owner.qr_sprite, 0, qr_x, qr_y, _scale, _scale, 0, c_white, alpha);

	gpu_set_texfilter(_prev);

	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_alpha(alpha);
	draw_set_colour(c_white);
	draw_text(qr_x + qr_size / 2, qr_y - 4, label);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

} else if (owner.qr_failed) {
	// Nothing here is essential to the exhibit, so fail quietly rather
	// than leaving a blank box that reads as a bug.
	draw_set_alpha(alpha);
	draw_set_colour(make_colour_rgb(40, 40, 40));
	draw_rectangle(qr_x, qr_y, qr_x + qr_size, qr_y + qr_size, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);

} else {
	// Still downloading. Only ever visible on a first run with a cold
	// cache — after that the disk cache makes this instantaneous.
	draw_set_alpha(alpha * 0.5);
	draw_set_colour(make_colour_rgb(40, 40, 40));
	draw_rectangle(qr_x, qr_y, qr_x + qr_size, qr_y + qr_size, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
}

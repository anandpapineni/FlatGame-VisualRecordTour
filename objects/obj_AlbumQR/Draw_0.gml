/// obj_AlbumQR — Draw
///
/// Regular Draw, not Draw GUI, so this sits in world space at the same
/// coordinates as obj_AlbumReview rather than in a separate GUI layer.

if (owner == noone || !instance_exists(owner)) exit;

if (owner.qr_ready && sprite_exists(owner.qr_sprite)) {

	// The one QR-specific thing in all of this: bilinear filtering smears
	// the module edges into grey and a scanner's threshold pass stops
	// finding them. Off before drawing, restored after.
	var _prev = gpu_get_texfilter();
	gpu_set_texfilter(false);

	var _scale = qr_size / sprite_get_width(owner.qr_sprite);
	draw_sprite_ext(owner.qr_sprite, 0, x, y, _scale, _scale, 0, c_white, 1);

	gpu_set_texfilter(_prev);

	draw_set_colour(c_white);
	draw_set_halign(fa_center);
	draw_text(x + qr_size / 2, y + qr_size + 8, label);
	draw_set_halign(fa_left);

} else if (owner.qr_failed) {
	// Silent failure would be confusing; a blank box reads as a bug.
	// Nothing here is essential to the exhibit, so keep it quiet.
	draw_set_colour(make_colour_rgb(40, 40, 40));
	draw_rectangle(x, y, x + qr_size, y + qr_size, false);
	draw_set_colour(make_colour_rgb(120, 120, 120));
	draw_set_halign(fa_center);
	draw_text(x + qr_size / 2, y + qr_size / 2, "code unavailable");
	draw_set_halign(fa_left);
	draw_set_colour(c_white);

} else {
	// Still downloading. Only visible on a first run with a cold cache —
	// after that the disk cache makes this instantaneous.
	draw_set_colour(make_colour_rgb(40, 40, 40));
	draw_rectangle(x, y, x + qr_size, y + qr_size, false);
	draw_set_colour(c_white);
}

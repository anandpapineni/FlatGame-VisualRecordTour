/// obj_AlbumQR — Step

// obj_AlbumReview destroys itself when the player presses space a second
// time. The album object doesn't know that happened — its myReview still
// points at a dead instance and it won't clean up until the player walks
// away. Without this the QR would be left hovering over nothing.
if (review != noone && !instance_exists(review)) {
	instance_destroy();
	exit;
}

// With wait_for_text off this just fades up as soon as the panel appears,
// so the code is on screen the whole time the text is typing.
var _target = 1;

if (wait_for_text && review != noone && instance_exists(review)) {
	_target = (review.char_current >= string_length(review.AlbumDescReview)) ? 1 : 0;
}

alpha += (_target - alpha) * fade_speed;
if (alpha > 0.999) alpha = 1;

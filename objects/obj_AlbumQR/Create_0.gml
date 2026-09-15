/// obj_AlbumQR — Create
///
/// Spawned and destroyed alongside obj_AlbumDetails and obj_AlbumReview.
/// Holds no QR data of its own — it draws whatever its owner album object
/// is holding, positioned against the review panel's own geometry.
///
/// Drawn in Draw GUI to match obj_AlbumReview. The instance's room x/y is
/// irrelevant; qr_x/qr_y below are GUI coordinates.

owner  = noone;			// the album object holding the sprite
review = noone;			// the obj_AlbumReview instance to sit above

qr_size = 160;			// on-screen size in GUI pixels
gap     = 14;			// space between the code and the top of the panel
label   = "Scan to listen";

// false: the code appears with the panel, while the text is still typing.
// true:  it's held back until the typewriter finishes.
wait_for_text = false;

// How quickly it fades in, per frame. 1 = appear instantly with no fade.
fade_speed = 0.2;

alpha = 0;

qr_x = 0;
qr_y = 0;

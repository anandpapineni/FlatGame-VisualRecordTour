myDesc   = noone;
myReview = noone;
myQR     = noone;

// ---------------------------------------------------------------------
//  This album's own data. Everything specific to Atrocity Exhibition
//  lives here rather than being buried in the Step event, so copying
//  this object to make the next album is a matter of editing one block.
// ---------------------------------------------------------------------

albumTitle = "Danny Brown's 'Atrocity Exhibition'";

albumText  = "Danny Brown trailblazes into completely uncharted territory with this Abstract Hip-Hop album. Atrocity Exhibition is an exploration of Danny's descent to rock bottom through drug addiction. Throughout the record, he portrays the dangers of this lifestyle through dueling lenses, with loud, chaotic, post-punk production layered with a manic and strained delivery representing the chaos and danger of this life, interspersed with brief reprieves of calm, self-reflective, and almost jazzy tracks where Brown ponders what he's lost in this pursuit of pleasure before throwing us back to the sea of chaos. There is a reason this is considered one of the best albums of its decade.";

// PASTE THE REAL LINK HERE.
// In the Spotify desktop app: right-click the album > Share > Copy Link.
// A "spotify:album:..." URI works too — spotify_share_url handles both.
albumURL = "https://open.spotify.com/album/3A1vnUJDPz0xYMful9pO4I?si=59Yz4CNbQtuC3L_0X4AKcQ";


// ---------------------------------------------------------------------
//  QR state. This object owns its URL; the cache is generic and just
//  maps URL -> sprite.
// ---------------------------------------------------------------------

qr_sprite = -1;
qr_ready  = false;
qr_failed = false;

on_qr_ready = function(_spr) {
	qr_sprite = _spr;
	qr_ready  = true;
};

on_qr_failed = function() {
	qr_failed = true;
};

qr_image_url = qr_url(spotify_share_url(albumURL), 512, "L");


// ---------------------------------------------------------------------
//  Get a handle on the cache.
//
//  Hold the instance id directly rather than reading global.qr_cache.
//  The global is set inside obj_QRCache's Create event, so relying on it
//  here means a silent dependency on that event having run — and if the
//  object was added to the project without its .gml files, it hasn't.
//  instance_create_depth returns the id regardless, so use that.
// ---------------------------------------------------------------------

var _cache = instance_exists(obj_QRCache)
           ? instance_find(obj_QRCache, 0)
           : instance_create_depth(0, 0, 0, obj_QRCache);

if (_cache != noone && instance_exists(_cache)
    && variable_instance_exists(_cache, "request")) {

	// Request at Create, not on player contact, so the download finishes
	// while they're still crossing the room and the code is already on
	// screen when the panel appears.
	_cache.request(qr_image_url, id);

} else {
	// Loud, specific, and non-fatal — the exhibit still works without it.
	show_debug_message("obj_QRCache is missing its Create event code: no request() method found. Check that the object's events were actually imported.");
	qr_failed = true;
}

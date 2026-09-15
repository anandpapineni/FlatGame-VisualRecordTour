/// obj_QRCache — Create
/// Persistent. Owns every QR sprite in the game. Album objects ask it for
/// a URL and get a callback; they never download or free anything.

global.qr_cache = id;

CACHE_DIR = "qrcache";

max_active = 4;			// concurrent downloads
active     = 0;

entries      = ds_map_create();		// url -> entry struct
by_sprite    = ds_map_create();		// sprite index -> url
queue        = [];
notify_queue = [];

if (!directory_exists(CACHE_DIR)) directory_create(CACHE_DIR);


/// @func cache_filename(url)
/// @desc QR URLs are long and full of characters filesystems reject, so
///       hash them. Different size/ECC/colour make a different URL and
///       therefore a different file, so variants can't overwrite each other.
cache_filename = function(_url) {
	return CACHE_DIR + "/" + md5_string_utf8(_url) + ".png";
};


/// @func request(url, inst)
/// @desc inst gets on_qr_ready(sprite) or on_qr_failed() later — never
///       synchronously, see the Step event.
request = function(_url, _inst) {

	// ---- already known ----
	if (ds_map_exists(entries, _url)) {
		var _e = entries[? _url];

		if (_e.state == 2 || _e.state == 3) {
			array_push(notify_queue, { inst: _inst, entry: _e });
		} else {
			array_push(_e.waiters, _inst);
		}
		return;
	}

	// ---- new entry ----
	var _e = {
		url     : _url,
		file    : cache_filename(_url),
		sprite  : -1,
		state   : 0,			// 0 queued  1 loading  2 ready  3 failed
		waiters : [_inst],
	};
	entries[? _url] = _e;

	// ---- disk hit ----
	if (file_exists(_e.file)) {
		var _spr = sprite_add(_e.file, 1, false, false, 0, 0);

		// Local loads are normally synchronous. Don't rely on it — if the
		// sprite isn't valid yet, let Image Loaded finish the job.
		if (sprite_exists(_spr)) {
			_e.sprite = _spr;
			_e.state  = 2;
			flush_waiters(_e);
			return;
		}

		_e.sprite = _spr;
		_e.state  = 1;
		by_sprite[? _spr] = _url;
		active++;
		return;
	}

	// ---- miss ----
	array_push(queue, _url);
	pump();
};


pump = function() {
	while (active < max_active && array_length(queue) > 0) {
		var _url = queue[0];
		array_delete(queue, 0, 1);

		var _e = entries[? _url];
		if (is_undefined(_e) || _e.state != 0) continue;

		// smooth = false. A filtered QR is a broken QR.
		var _spr = sprite_add(_url, 1, false, false, 0, 0);

		_e.sprite = _spr;
		_e.state  = 1;
		by_sprite[? _spr] = _url;
		active++;
	}
};


flush_waiters = function(_e) {
	for (var i = 0; i < array_length(_e.waiters); i++) {
		array_push(notify_queue, { inst: _e.waiters[i], entry: _e });
	}
	_e.waiters = [];
};


/// @func clear_disk_cache()
/// @desc Filenames are hashes, so changing a code's size or colours
///       orphans the old file rather than replacing it. Call on a version
///       bump if the folder starts growing.
clear_disk_cache = function() {
	var _f = file_find_first(CACHE_DIR + "/*.png", 0);
	while (_f != "") {
		file_delete(CACHE_DIR + "/" + _f);
		_f = file_find_next();
	}
	file_find_close();
};

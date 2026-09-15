/// obj_QRCache — Async > Image Loaded
///
/// ONLY this object defines this event. GameMaker fires the async event in
/// every instance that has it, handing each the same async_load map — so if
/// the album objects defined it too, each one would wake up for every other
/// album's download. Routing everything through here avoids that entirely.

var _spr = async_load[? "id"];
if (!ds_map_exists(by_sprite, _spr)) exit;

var _url = by_sprite[? _spr];
ds_map_delete(by_sprite, _spr);

var _e = entries[? _url];
active = max(0, active - 1);

if (async_load[? "status"] >= 0 && sprite_exists(_spr)) {
	_e.sprite = _spr;
	_e.state  = 2;

	// Write it out so the next launch skips the network. Only for a fresh
	// download — re-saving one we just read off disk is pointless churn.
	if (!file_exists(_e.file)) {
		sprite_save(_spr, 0, _e.file);
	}
} else {
	_e.sprite = -1;
	_e.state  = 3;
	show_debug_message("QR failed: " + _url);
}

flush_waiters(_e);
pump();

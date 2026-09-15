/// obj_QRCache — Clean Up
///
/// The cache owns every sprite, so it frees them and nobody else does.
/// Album objects must NOT sprite_delete a QR — two albums with the same
/// link legitimately share one sprite.

var _keys = ds_map_keys_to_array(entries);
for (var i = 0; i < array_length(_keys); i++) {
	var _e = entries[? _keys[i]];
	if (_e.sprite != -1 && sprite_exists(_e.sprite)) sprite_delete(_e.sprite);
}

ds_map_destroy(entries);
ds_map_destroy(by_sprite);

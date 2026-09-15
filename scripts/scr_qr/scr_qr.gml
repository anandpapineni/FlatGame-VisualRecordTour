/// scr_qr — helpers for building QR image URLs.

/// @func url_encode(str)
/// @desc Percent-encodes a string for use in a query parameter.
function url_encode(_str) {
	var _hex = "0123456789ABCDEF";
	var _out = "";
	var _n   = string_byte_length(_str);

	for (var i = 1; i <= _n; i++) {
		var _b = string_byte_at(_str, i);

		// Unreserved: A-Z a-z 0-9 - _ . ~
		if ((_b >= 48 && _b <= 57)
		 || (_b >= 65 && _b <= 90)
		 || (_b >= 97 && _b <= 122)
		 ||  _b == 45 || _b == 95 || _b == 46 || _b == 126) {
			_out += chr(_b);
		} else {
			_out += "%"
			      + string_char_at(_hex, (_b >> 4) + 1)
			      + string_char_at(_hex, (_b & 15) + 1);
		}
	}
	return _out;
}


/// @func colour_to_hex(col)
/// @desc GameMaker colour -> "RRGGBB". GM stores colours as BGR
///       internally, so use the accessors rather than shifting the raw value.
function colour_to_hex(_col) {
	var _digits = "0123456789ABCDEF";
	var _parts  = [colour_get_red(_col),
	               colour_get_green(_col),
	               colour_get_blue(_col)];
	var _out = "";

	for (var i = 0; i < 3; i++) {
		_out += string_char_at(_digits, (_parts[i] >> 4) + 1)
		      + string_char_at(_digits, (_parts[i] & 15) + 1);
	}
	return _out;
}


/// @func qr_url(data, [px], [ecc], [fg], [bg], [quiet])
/// @desc Builds a QR image URL from api.qrserver.com. Free, no API key.
function qr_url(_data, _px = 128, _ecc = "L",
                _fg = c_black, _bg = c_white, _quiet = 4) {

	return "https://api.qrserver.com/v1/create-qr-code/"
	     + "?size="    + string(_px) + "x" + string(_px)
	     + "&ecc="     + _ecc
	     + "&color="   + colour_to_hex(_fg)
	     + "&bgcolor=" + colour_to_hex(_bg)
	     + "&qzone="   + string(_quiet)
	     + "&format=png"
	     + "&data="    + url_encode(_data);
}


/// @func spotify_share_url(uri_or_url)
/// @desc Normalises a Spotify URI or share link into a clean https URL
///       with no "?si=" tracking string. Those 20-odd characters often
///       push the symbol up a version, making the modules smaller and
///       the code fussier to scan.
function spotify_share_url(_ref) {
	var _s = _ref;

	if (string_pos("spotify:", _s) == 1) {
		// spotify:album:xxxx -> https://open.spotify.com/album/xxxx
		var _p1   = string_pos(":", _s);
		var _rest = string_delete(_s, 1, _p1);
		var _p2   = string_pos(":", _rest);
		var _type = string_copy(_rest, 1, _p2 - 1);
		var _id   = string_delete(_rest, 1, _p2);
		return "https://open.spotify.com/" + _type + "/" + _id;
	}

	var _q = string_pos("?", _s);
	if (_q > 0) _s = string_copy(_s, 1, _q - 1);
	return _s;
}

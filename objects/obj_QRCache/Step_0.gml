/// obj_QRCache — Step
///
/// Callbacks drain here rather than firing inline, so a cache hit and a cold
/// download look identical from the album object's side. Notifying
/// immediately on a hit would mean on_qr_ready could run partway through the
/// album object's own Create event, before the rest of its variables exist.

if (array_length(notify_queue) > 0) {
	var _n = notify_queue;
	notify_queue = [];

	for (var i = 0; i < array_length(_n); i++) {
		var _inst = _n[i].inst;

		// The album object may have been destroyed on a room change while
		// its request was still in flight.
		if (_inst == noone || !instance_exists(_inst)) continue;

		var _e = _n[i].entry;
		if (_e.state == 2) {
			with (_inst) on_qr_ready(_e.sprite);
		} else {
			with (_inst) on_qr_failed();
		}
	}
}

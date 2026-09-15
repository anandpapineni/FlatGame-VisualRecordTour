/// obj_AtrocityExhibition — Step

if (place_meeting(x, y, obj_Player))
{
	// NOTE: the braces around this block are new and they matter — see
	// the README. Previously only the first line was guarded by the
	// myDesc check, so the review object was being recreated every frame
	// the player stood here.
	if (myDesc == noone)
	{
		myDesc = instance_create_layer(x, y, "AlbumTextLayer", obj_AlbumDetails);
		myDesc.AlbumDescReview = albumTitle;

		myReview = instance_create_depth(-700, -400, -1000, obj_AlbumReview);
		myReview.AlbumDescReview = albumText;

		// Drawn in Draw GUI, so the room position here is irrelevant —
		// it positions itself against the review panel's own geometry.
		// Depth is one lower than the panel so it draws in front.
		myQR = instance_create_depth(x, y, -1001, obj_AlbumQR);
		myQR.owner  = id;
		myQR.review = myReview;
	}
}
else
{
	if (myDesc != noone)
	{
		instance_destroy(myDesc);
		instance_destroy(myReview);
		instance_destroy(myQR);

		myDesc   = noone;
		myReview = noone;
		myQR     = noone;
	}
}

if(place_meeting(x, y, obj_Player))
{
	if(myDesc == noone)
		myDesc = instance_create_layer(x,y, "AlbumTextLayer", obj_AlbumDetails);
		myDesc.AlbumDescReview = "Schoolboy Q's 'Blue Lips'";
myReview = instance_create_depth(-700, -400, -1000, obj_AlbumReview);
		myReview.AlbumDescReview = "I love my wife."
}
else
{
		if(myDesc != noone)
		{
			instance_destroy(myDesc);
			instance_destroy(obj_AlbumReview);
			myDesc = noone;
			myReview = noone;
		}
}
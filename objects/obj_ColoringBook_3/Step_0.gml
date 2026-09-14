if(place_meeting(x, y, obj_Player))
{
	if(myTextbox == noone)
		myTextbox = instance_create_layer(x,y, "AlbumTextLayer", obj_AlbumDesc);
		myTextbox.AlbumDescReview = "Chance The Rapper's 'Coloring Book'";
}
else
{
		if(myTextbox != noone)
		{
			instance_destroy(myTextbox);
			myTextbox = noone;
		}
}
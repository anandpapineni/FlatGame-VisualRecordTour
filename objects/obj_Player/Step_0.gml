x=clamp(x, 16, 1684) //max screen width
y=clamp(y, 16, 1384) // max screen height
if (keyboard_check(vk_left))
{
    x = x - 5;
	spin_speed = 5;
	image_angle += spin_speed 
}
else if (keyboard_check(vk_right))
{
    x = x + 5;
	spin_speed = 5;
	image_angle -= spin_speed 
}
else if (keyboard_check(vk_up))
{
    y = y - 5;
	if(spin_speed != 0)
		image_angle += spin_speed
	else
	{
		spin_speed = choose(5, -5);
	}
}
else if (keyboard_check(vk_down))
{
    y = y + 5;
	if(spin_speed != 0)
		image_angle += spin_speed
	else
	{
		spin_speed = choose(5, -5);
	}
}
else
{
	spin_speed = 0;
}
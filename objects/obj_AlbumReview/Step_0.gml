// Increase the character count over time
if (char_current < string_length(AlbumDescReview)) {
    char_current += char_speed;
}

// Optional: Allow player to skip the typing animation by pressing Space
if (keyboard_check_pressed(vk_space)) {
    if (char_current < string_length(AlbumDescReview)) {
        char_current = string_length(AlbumDescReview); // Skip to the end
    } else {
        
        instance_destroy(); 
    }
}
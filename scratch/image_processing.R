
# read in image of trees
image <- image_read("myapp/www/images/forest.png")

# decrease resolution
pixelated_image2 <- image_scale(pixelated_image,"360x360!")

# write image
image_write(pixelated_image2, "myapp/www/images/forest_pix.png")






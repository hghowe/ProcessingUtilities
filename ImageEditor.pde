// version 1.2
// September 15, 2016
// author: Harlan Howe

/**
   Summary of methods in ImageEditor
   =>There are five ways you can create a new ImageEditor: you can give it ...
       • an existing PImage,
       • a filename (which will load this file), or
       • a width & height (which will create a blank, black image)
       • a width & height & color (which will create a blank image with the color)
       • an (x, y, w, h) rectangle, which will copy the contents of the current window into a new ImageEditor.
     For example, you might say:
       ImageEditor editor = new ImageEditor("picture.jpg");
       or
       ImageEditor editor = new ImageEditor(600,600,new color(128,0,255));

  =>You can ask an ImageEditor for its width() or for its height()
  
  =>You can ask the ImageEditor to resize the main window to the size of this picture, or a multiple of the size of the picture:
    For example, if the image is (320 x 240) you might say
        editor.resizeWindowToImage();  // this would make the window be (320 x 240)
        or
        editor.resizeWindowToImage(2,1); // this would make the window be (640 x 240)
  
  =>You can have the ImageEditor draw its image onto the main window with its upper-left corner at a specific coordinate:
        editor.drawAt(0,0);
    This only works when you are NOT in "Editing Mode."
        
  =>You can set the ImageEditor into "Editing Mode" - this is the mode in which you can read and write pixel data, but you cannot
    draw while you are in this mode.
        editor.startEditing();
        editor.stopEditing();
    You can also ask whether it is in "Editing Mode."
        if (editor.isEditing())
            println("In editing mode.");

  =>In "Editing Mode," you can ask for color information for a given pixel:
       •editor.getRedAt(x,y); // returns a number 0-255
       •editor.getGreenAt(x,y); // returns a number 0-255
       •editor.getBlueAt(x,y); // returns a number 0-255
       •editor.getColorAt(x,y); // returns a huge "color" number (0 - 4,294,967,295) that represents the full RGB value.
                                // this large color number is the sort of thing you get when you say "new color(255,128,0)"
       
  =>In "Editing Mode," you can change the color information for a given pixel:
       •editor.setRedAt(r,x,y);
       •editor.setGreenAt(g,x,y);
       •editor.setBlueAt(b,x,y);
       •editor.setColorAt(c,x,y);

  =>In any mode, you can ask whether a given set of coordinates fits within the size of this PImage:
       •if (editor.inBounds(x,y))
           println("Yep, it's in bounds.");

  =>If you are not in "Editing Mode," you can ask for the PImage in this ImageEditor.
       •PImage imageCopy = editor.getImage();

*/
class ImageEditor
{
  int myWidth, myHeight, myNumPixels;
  PImage myImage;
  color[] myPixels;
  boolean isEditing;
  
  

  /**
  * loads the given filename and creates an imageEditor of it.
  * @param the name of the file holding an image that we should use.
  */
  ImageEditor(String filename)
  {
     this(loadImage(filename));  
  }

  /**
  * creates an ImageEditor of specified (width,height) that starts off blank - using ARGB format.
  * @param width - the width of the blank image created.
  * @param height  the height of the blank image created.
  */
  ImageEditor(int width, int height)
  {
     this(createImage(width,height,ARGB)); 
  }
  
  /**
  * creates an ImageEditor of specified (width,height) that starts off filled with color c - using ARGB format.
  * @param width - the width of the blank image created.
  * @param height - the height of the blank image created.
  * @param color - which color goes in each pixel.
  */
  ImageEditor(int width, int height, color c)
  {
     this(width,height);
     for (int x = 0; x<width; x++)
       for (int y = 0; y<height; y++)
         setColorAt(c,x,y);
  }
  /*
  * creates an ImageEditor of specified (w, h) that is filled with content from the screen,
  * using the rectangular section (startX, startY, w, h) as the source of that content.
  * Note: the rectangular section must fall within the confines of the screen.
  */
  ImageEditor(int startX, int startY, int w, int h)
  {
     this(w,h);
     if (startX+w>width || startY+h>height)
       throw new RuntimeException("Attempted to create image with rectangular data from ("+
                                   startX+", "+startY+") to ("+(startX+w)+", "+(startY+h)+
                                   "), but the screen is only "+width+" x "+height+" pixels.");
     loadPixels();
     startEditing();
     for (int y = 0; y<h; y++)
        for( int x = 0; x<w; x++)
          setColorAt(pixels[(startX+x)+width*(startY+y)], x,y);
     stopEditing();
     updatePixels();
  }  
  
  /**
  * creates an ImageEditor with a <i>copy</i> of the specified image, starting off out of editing mode.
  * @param inImage - the image to copy and use.
  */
  ImageEditor(PImage inImage)
  {
      if (inImage == null)
      {
        throw new RuntimeException("Attempted to create an ImageEditor with a null image.");
      }
    myImage = createImage(inImage.width,inImage.height,ARGB);
    myImage.copy(inImage,0,0,inImage.width,inImage.height,0,0,inImage.width,inImage.height);
    myWidth = myImage.width;
    myHeight = myImage.height;    
    myNumPixels = myWidth * myHeight;
    isEditing = false;
  }
  
  int width()
  {   return myWidth; }
  
  int height()
  {   return myHeight; }
  
  boolean isEditing()
  {   return isEditing; }
  
  
  /**
  * enter "editing mode" - you can now read and manipulate pixel data, but you
  * cannot draw the image until you exit this mode.
  */
  void startEditing()
  {
     if (!isEditing)
     {
       myImage.loadPixels();
       myPixels = myImage.pixels;
       isEditing = true;
     }
  }
  
  
  /**
  * exit "editing mode" - you can no longer read or manipulate pixel data,
  * but you can now draw the image.
  */
  void stopEditing()
  {
    if (isEditing)
    {
      myImage.updatePixels();
      isEditing = false;
    }
  }
  
  
  /**
  * indicates whether the given point is within this image.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  boolean inBounds(int x, int y)
  {
    return (x>=0) && (x<myWidth) && (y>=0) && (y<myHeight);
  }
  
  /**
  * returns the pixel color value at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the color of the pixel at (x,y)
  */
  color colorAt(int x, int y)
  {
    if (!isEditing)
      throw new RuntimeException("Attempted to get pixel data at ("+x+", "+y+") but image is not in editing mode.");
    if (!inBounds(x,y))
      throw new RuntimeException("Attempted to get pixel data at ("+x+", "+y+") but this must fall between (0,0) and ("+(myWidth-1)+", "+(myHeight-1)+"), inclusive.");
    return myPixels[x+myWidth*y];
  }
  /**
  * returns the red value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the color of the pixel at (x,y)
  */
  int getRedAt(int x, int y)
  {
    return getRedForColor(colorAt(x,y));
  }
    /**
  * returns the green value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the color of the pixel at (x,y)
  */
  int getGreenAt(int x, int y)
  {
    return getGreenForColor(colorAt(x,y));
  }
    /**
  * returns the blue value  (0-255) at the given coordinates.
  * Note: editing mode must be on to use this method.
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  * @return the color of the pixel at (x,y)
  */
  int getBlueAt(int x, int y)
  {
    return getBlueForColor(colorAt(x,y));
  }
  
  /**
  * updates the red portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the redness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setRedAt(int val, int x, int y)
  {
     setColorAt(changeRedInColor(colorAt(x,y),val), x, y); 
  }
  
  /**
  * updates the green portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the greenness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setGreenAt(int val, int x, int y)
  {
     setColorAt(changeGreenInColor(colorAt(x,y),val), x, y); 
  }
  /**
  * updates the blue portion of the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the blueness (0-255) to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setBlueAt(int val, int x, int y)
  {
     setColorAt(changeBlueInColor(colorAt(x,y),val), x, y); 
  }
  
  /**
  * updates the color at the given (x,y) coordinates.
  * note: editing mode must be on to use this method.
  * @param c - the color to which the pixel should be set
  * @param x - the x-coordinate of the pixel
  * @param y - the y-coordinate of the pixel
  */
  void setColorAt(color c, int x, int y)
  {
    if (!isEditing)
      throw new RuntimeException("Attempted to set pixel data at ("+x+", "+y+") but image is not in editing mode.");
    if (!inBounds(x,y))
      throw new RuntimeException("Attempted to set pixel data at ("+x+", "+y+") but this must fall between (0,0) and ("+(myWidth-1)+", "+(myHeight-1)+"), inclusive.");
    myPixels [x+myWidth*y] = c;
  }

  /**
  * draws the image at the given (x,y) location.
  * Note: this throws an exception (i.e., crashes) if we are in editing mode.
  * @param x - the x-coordinate in the current Matrix where the upper-left image of the image will start.
  * @param y - the y-coordinate in the current Matrix where the upper-left image of the image will start.
  */
  void drawAt(int x, int y)
  {
     if (isEditing)
       throw new RuntimeException("Attempted to draw image while in \"Editing Mode.\"");
     image(myImage,x,y);  
  }
  
  /**
  * returns a copy of the PImage used in this ImageEditor; further edits to this ImageEditor will
  * not affect the copy returned.
  * @return a copy of the PImage currently used in this ImageEditor. 
  */
  PImage getImage()
  {
    if (isEditing)
       throw new RuntimeException("Attempted to grab image from Image Editor while in \"Editing Mode.\"");
    PImage tempImage = createImage(myWidth, myHeight,ARGB);
    tempImage.copy(myImage,0,0,myWidth,myHeight,0,0,myWidth,myHeight);
    return tempImage;
    
  }

  /**
  * changes the size of the main window to match that of the PImage used in this ImageEditor.
  */  
  void resizeWindowToImage()
  {
     surface.setSize(myWidth,myHeight); 
  }
  
  /**
  * changes the size of the main window to a multiple of the width and height of this ImageEditor's PImage.
  * @param mx - the integer multiplier for x
  * @param my - the integer multiplier for y
  * precondition: mx and my are both >= 1.
  */
  void resizeWindowToImage(int mx, int my)
  {
    surface.setSize(myWidth*max(1,mx), myHeight*max(1,my));

  }
  
  
  /********************************************************************************************************
  * THE MATERIAL PAST THIS POINT IS USED BY OTHER METHODS IN THIS CLASS. YOU DO NOT NEED TO WORRY ABOUT IT.
  * PLEASE DO NOT CHANGE IT.
  */
  
  final int ALPHA_BIT_SHIFT = 24;
  final int RED_BIT_SHIFT = 16;
  final int GREEN_BIT_SHIFT = 8;
  final int BLUE_BIT_SHIFT = 0;
  final int ALL_ONES = (int)(Math.pow(2,32)-1);
  
  int getRedForColor(color c)
  {
    return getBitsAtShift(c,RED_BIT_SHIFT);
  }
  
  int getGreenForColor(color c)
  {
    return getBitsAtShift(c,GREEN_BIT_SHIFT);
  }
  
  int getBlueForColor(color c)
  {
    return getBitsAtShift(c,BLUE_BIT_SHIFT);
  }
  
  int getBitsAtShift(color c, int shift)
  {
    return (c & (255<<shift)) >> shift;
  }
  
  color changeRedInColor(color c, int val)
  {
    return ((val & 255)<<RED_BIT_SHIFT) | (c &(ALL_ONES - (255<<RED_BIT_SHIFT)));
  }
  color changeGreenInColor(color c, int val)
  {
    return ((val & 255)<<GREEN_BIT_SHIFT) | (c &(ALL_ONES - (255<<GREEN_BIT_SHIFT)));
  }
  color changeBlueInColor(color c, int val)
  {
    return ((val & 255)<<BLUE_BIT_SHIFT) | (c &(ALL_ONES - (255<<BLUE_BIT_SHIFT)));
  }

  
  
}
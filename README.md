# photoOrganize
A swift script to organize my photos.

Photos will be renamed as such:
* Original: img_3185.jpg
* Updated: 20161129-145929-christmas-img_3185.jpg

The photo or video creation date is add to the beginning of the file.  This this is helpful for sorting.  

The original filename is preserved.  This is useful to keep the original filename and to avoid duplicates.

Optionally you can add a photo identifer that will help you organize your photos.

Images will be put into a directory: images

Vidoes will be put into a directory: videos

Live Photos will be put into images with and named the same as the photo.

Parameters:
1. Input Directory.  This is a flat directory containing the photos and videos
2. Output Direcoty.  File will be copied here.
3. Photo Identifier.  A string that will be added to the name to help identify the photos.

**Example**
```
$ marathon run photoOrganize.swift input output christmas
$ marathon run https://github.com/dougdiego/photoOrganize.git input output christmas
```

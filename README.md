# metaDataBot
Discord Bot for displaying metadata (image parameters) of posted images. Used with AI generated images to view their DNA.

Based on [Defxult/Discord Bot](https://github.com/Defxult/Discord.swift)

This bot can post the image generation parameters, stored in the metadata of an image when it's posted to your Discord server.

metaDataBot is public, and available for install on any Discord server.
metaDataBot runs on MacOS

### Usage

type `exifbot help` to see its commands

>exifbot help
```
exifbot commands:
Precede commands with "exifbot ", eg: "exifbot lastimage"

  lastimage OR @ParamPeek: display the metadata for the most recent image posted in the current channel
Modes:
  mute: report image metadata only when requested, via 'lastimage'  
  unmute: post metadata after all images (default)
  brief: display only prompt & negative prompt  
  full: post metadata after all images (default)  
Other  
  wrong: report incorrect or badly formatted image data  
  version: version info  
  about: about exifbot  
  help: show this message  

You can also DM Me an image to see its metadata
```
### Methods

Acquiring data:
metaDataBot looks for EXIF data in the image, which is usually (but not always? what are the criteria) stripped by Discord. EXIF is preferred because it is valid JSON. If no exif found, it looks for TIFF dictionary

metadata is posted as a text file

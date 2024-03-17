# metaDataBot
Discord Bot that displays the DNA of an AI generated image. 

This bot can post the image generation parameters stored in the metadata of an image which is posted on Discord. When discussing and sharing AI images, one typically wishes to see how an image was created. Without such a tool, users must download the image and open in some app to see that info. This bot displays it conveniently inline.

metaDataBot is public, and available for install on any Discord server. metaDataBot requires `PRESENCE INTENT`, `SERVER MEMBERS INTENT`, and `MESSAGE CONTENT INTENT` on your server. metaDataBot runs on MacOS. metaDataBot doesn't like it when you take about them in the third person, even though they're standing right there.

### Usage

Bot can respond to all images, or none, or just on request. It can post just the image prompts, or their full list of parameters. It also works via DM - DM the bot an image to get its parameters. You can summon the bot with @ParamPeek to see parameters of the most recently posted image in a channel.  
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

metaDataBot looks for EXIF data in the image, which is usually (but not always? what are the criteria) stripped by Discord. EXIF is preferred because it is valid JSON. If no exif found, it looks for TIFF dictionary. Data from EXIF has the prompt field labeled as "c", and the negative prompt as "uc". Those are relabeled as "prompt" and "negative_prompt". All other fields are passed straight through.

metadata is posted as an attached text file

### Building  
You can build the bot in xcode from this source, but it won't be able to log in to discord - the confidential token has been removed. There can be only one.

### Acknowledments

The awesome community on the [Draw Things discord.](https://discord.gg/Zx9VXSqQUK)  
Built on [Defxult/Discord Bot](https://github.com/Defxult/Discord.swift)

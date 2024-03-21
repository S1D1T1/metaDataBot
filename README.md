# metaDataBot
Discord Bot that displays the DNA of an AI generated image. 

This bot can post the image generation parameters of an image which is posted on Discord. When discussing and sharing AI images, one typically wants to see the specific settings and parameters used to create it. Without this bot, users must download the image and open in some app to see that info. This bot reads that info from the file's *metadata* and displays it conveniently inline.  
Sometimes that data is not attached, and again, you'd have to download the image and examine it to know. This bot can at least quickly confirm if the metadata is there. 

metaDataBot is live and publicly available on Discord, to install on any server - or for any individual user - by clicking the link below. It's not required that you build it yourself. If installing metadataBot on your server, it requires `PRESENCE INTENT`, `SERVER MEMBERS INTENT`, and `MESSAGE CONTENT INTENT` permissions. metaDataBot runs on MacOS. metaDataBot doesn't like it when you take about them in the third person, when they're standing right there.

[MetaDataBot Installation Link](https://discord.com/oauth2/authorize?client_id=1218037339276836997)

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
  about: about exifbot  
  help: show this message  

You can also DM Me an image to see its metadata
```
### Methods

metaDataBot looks for EXIF data in the image, which Discord usually strips off (but not always? what are the criteria). EXIF is preferred because it is valid JSON. If no exif found, it looks for TIFF dictionary. Data from EXIF has the prompt field labeled as "c", and the negative prompt as "uc". Those are relabeled as "prompt" and "negative_prompt". All other fields are passed straight through.

Metadata is posted as an attached text file. Reason for it being a file as opposed to inline text is just to be less obtrusive - file attachments can collapse down.

<img width="683" alt="Screenshot 2024-03-17 at 1 37 59 PM" src="https://github.com/S1D1T1/metaDataBot/assets/156350598/2b8ff4f1-3a44-4c1e-9ec5-45800e67dc75">


### Build & Run  
This source compiles the Discord bot executable. For the bot to actually log in to Discord, you need a confidential token obtained from the [Discord Developer Portal](https://discord.com/developers/applications). After acquiring the token, enter it into the file, `runbot.sh`. Ensure both `runbot.sh` and the discordbot executable are in the same folder. To run the bot, navigate to this folder in the terminal and execute `sh ./runbot.sh`

### Acknowledments
The awesome community on the [Draw Things discord.](https://discord.gg/Zx9VXSqQUK)  
Built on [Defxult/Discord Bot](https://github.com/Defxult/Discord.swift)

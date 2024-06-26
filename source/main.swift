//
//  main.swift
//  discordbot
//
// copyright 2024 (c) SoDoTo
// MIT License

import Foundation
import Discord
import SwiftUI  // for @AppStorage
import AppKit

// MARK: setup

class ExifbotState {
  var bot:Bot
  var saveLogString = ""  // use new sys logging feature
  var botState:responseMode = .muteMode
  var lastURL = ""

  // stats
  @AppStorage("imageCount") var imageCount = 0
  @AppStorage("maxParameters") var maxParameters = 0
  @AppStorage("startDate") var startDate = ""

  init() {
    let  myIntents:Set<Intents> = [.guildMessages,.messageContent,.dmMessages]
    guard  let token = ProcessInfo.processInfo.environment["METADATABOT_DISCORD_TOKEN"] else {
      print("Could not retrieve confidential token from environment variable: METADATABOT_DISCORD_TOKEN")
      print("Exiting")
      exit(0)
    }
    self.bot = Bot(token: token, intents: myIntents)
    self.bot.once {

      // set status when connected
      let presenceString = "Pics. @ParamPeek for metadata"
      self.bot.updatePresence(status:.online , activity:.watching(presenceString))
      if self.startDate.isEmpty { self.startDate = Date().description }
    }
  }
}

enum responseMode : Int { case normalMode=0, muteMode, promptOnlyMode }

var exifbotState = ExifbotState()

// MARK: Info Strings

let helpString =
"""
@ParamPeek to post metadata of images
If you @ Me in a *reply* to an image post, I'll examine that image.

## exifbot commands:

Precede commands with "exifbot ", eg: "exifbot lastimage"

  **lastimage**: display the metadata for the most recent image posted in the current channel
  **wrong**: report incorrect or badly formatted image data
  **about**: about exifbot
  **help**: show this message

You can also DM Me an image to see its metadata
"""

let aboutString =
"""
exifbot version 0.2
MIT License
copyright(c) 2024 @sodot0
<https://github.com/S1D1T1/metaDataBot>

Built using Discord Swift library by @Defxult. MIT License
<https://github.com/Defxult/Discord.swift>
"""
let errorString =
"""
Thanks for the feedback. We'll take a look.
Feel free to DM me any details about what was wrong
"""

/*
### Modes:
  **mute**: report image metadata only when requested, via 'lastimage'
  **unmute**: post metadata after all images (default)
  **brief**: display only prompt & negative prompt
  **full**: post metadata after all images (default)
*/

runbot()  //  this never returns

//-----------------------------

func runbot() {
  log("Starting up")

  let bot = exifbotState.bot

  try! bot.addListeners(ExifbotListener(name: "exifbot"))


//  bot.addSlashCommand(
//      name: "exifcommand",
//      description: "Example command",
//      guildId: nil,
//      onInteraction: { interaction in
//          try! await interaction.respondWithMessage("sample slash command", ephemeral: true)
//      }
//  )

//  Task{
//    try! await bot.syncApplicationCommands() // Only needs to be done once
//  }
  bot.run()
}

class ExifbotListener : EventListener {
  var presenceString = ""

  func setExifMode(_ response:String, _ mode:responseMode, _ message: Message) {
    say (response,message.channel)
    exifbotState.botState = mode    //  † not scalable. Needs to be on a per-server basis

    // display current activity level

    switch exifbotState.botState {
      case .muteMode:
        presenceString = "Pics. @me for metadata"
        log("setting mode: mute",message.channel)

      case .normalMode:
        presenceString = "Pics, posting params"
        log("setting mode: unmute",message.channel)
      case .promptOnlyMode:
        presenceString = "Pics, posting only prompts"
        log("setting mode: prompts only",message.channel)
    }
    message.channel.bot?.updatePresence(status:.online , activity:.watching(presenceString))
  }

  // perform the 'lastimage' command. search back through that channel & retro-analyze
  func lastImage(_ message:Message) async{
    do {
      let pastMessages = try await message.channel.history()
      print(pastMessages.count)

      for aMessage in pastMessages {
        if !aMessage.attachments.isEmpty,
           let theType = aMessage.attachments[0].contentType,
           theType.starts(with: "image/") {
          // post a link to the message we found
          say(aMessage.jumpUrl,message.channel)
          postImageMetadata(aMessage.attachments[0],aMessage)
          return
        }
      }
    }
    catch {}
  }

///  post metadata of the image attached to this message, in this channel
  func postImageMetadata(_ attachment: Message.Attachment, _ message: Message) {

    if let u = URL(string: attachment.url) {
      log(attachment.url)
      exifbotState.lastURL = attachment.url
      handleImage(u,message)
      return
    }
  }

  /// check message for image attachments, post metadata if found.
  fileprivate func processImagePost(_ message: Message) {
    for attachment in message.attachments {
      if let theType = attachment.contentType,
         theType.starts(with: "image/") {
        postImageMetadata(attachment, message)
      }
    }
  }
  
  ///  watch messages & respond
  override func onMessageCreate(message: Message) async {
    // Don't respond to our own message
    guard !message.author.isBot else {
      return
    }
    // MARK: Bot Commands

    if message.isMentioned{
      if let referencedMessage = message.referencedMessage {
        say("Getting metadata for referenced Message:",message.channel)
        say(referencedMessage.jumpUrl,referencedMessage.channel)
        processImagePost(referencedMessage)
      }
      else {
        say("Getting metadata for most recent image in this channel",message.channel)
        await lastImage(message)
      }
    }
    else if message.content.lowercased() == "exifbot lastimage" {
      say("Getting metadata for most recent image in this channel",message.channel)
      await lastImage(message)
    }

    else if message.content == "hi exifbot" {
      say("Hello",message.channel)
    }

/*

    else if message.content.lowercased() == "exifbot mute" {
      setExifMode("muting",.muteMode,message)
    }

    else if message.content.lowercased() == "exifbot unmute" {
      setExifMode("unmuting",.normalMode,message)
    }
    else if message.content.lowercased() == "exifbot brief" {
      setExifMode("prompts only",.promptOnlyMode,message)
    }

    else if message.content.lowercased() == "exifbot full" {
      setExifMode("full metadata",.normalMode,message)
    }
*/



    else if message.content.lowercased() == "exifbot about" {
      aboutExifBot(message.channel)
    }

    else if message.content.lowercased() == "exifbot wrong" {
      log("User Reports error", message.channel)
      say ("Problem reported processing the previous image, at URL:<\(exifbotState.lastURL)>",message.channel)
      say (errorString,message.channel)
    }

    else if message.content.lowercased() == "exifbot help" {
      say (helpString,message.channel)
    }

    // MARK: Image Attachments
    else if !message.attachments.isEmpty,
            exifbotState.botState != .muteMode {
      processImagePost(message)
    }
  }
}

// MARK: Sending messages & files

func say(_ s:String,_ channel:Messageable)  {
  Task {
    do{
      try await channel.send(s)
    }
    catch{}
  }
}

func sendAsFile(_ s:String,filename:String = "metadata.txt",_ channel:Messageable){
  Task {
    do{
      if !s.isEmpty,
         let data = s.data(using: .utf8) {
        let fileEmbed = File(name: filename, using: data)
        try await channel.send(files:[fileEmbed])
      }
    }
    catch{}
  }
}

// lets talk about me.
func aboutExifBot(_ channel:Messageable){
  var sayString = aboutString
  sayString.append("\n\(exifbotState.imageCount) Images processed, Since starting on \(exifbotState.startDate)\n")
  sayString.append("Parameter High Score: \(exifbotState.maxParameters) parameters")
  say(sayString,channel)
}


func log(_ s:String, _ channel:Messageable? = nil){

  let now = Date().description.replacingOccurrences(of: " +0000", with: "")
  var logString = "ExifBot - \(now):\(s)\n"
  if let channel {
    logString.append("channel ID: \(channel.id)")
  }
  print(logString)
  exifbotState.saveLogString.append("\(logString)\n")
}


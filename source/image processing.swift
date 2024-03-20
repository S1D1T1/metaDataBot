//
//  image processing.swift
//  discordbot
//
//  Created by sodoto on 3/16/24.
//
// MIT License

import Foundation
import Discord
import AppKit //  Core graphics

// MARK: Image Metadata parsing

// post metadata about the image at this url, in the provided channel
func handleImage(_ u:URL, _ message:Message){

  let channel = message.channel
  if let params =   getEmbeddedParamString(u) {
    
    // this will branch out to other special cases to ignore.
    if params == "Screenshot" {return}
    
    if let user = message.author.displayName {
      say("###  \(user) posted an image.",message.channel)
      log("image posted by \(user)",message.channel)
      exifbotState.imageCount += 1
      log("Image Count: \(exifbotState.imageCount)")
    }

    if let dictionary = JsonStringtoDict(params) {
      // here we go. translations
      let translatedParams = translateParams(dictionary)
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: translatedParams, options: [.prettyPrinted,.sortedKeys])
        if let jsonString = String(data: jsonData, encoding: .utf8) {
          log("posting \(translatedParams.count) params as json")
          trackParameterHighScore(translatedParams.count, channel:channel)
          sendAsFile("\(jsonString)",filename:"metadata.js", channel) //  send as a js file since this is actual valid json
        }
      }
      catch{}
    }
    else {
      // announce the prompts
      announceDescriptionString(params,channel)
    }
  }
}

// translation table for parameters which are in well-formed json.
// "c" -> "prompt" and "uc" -> "negative_prompt". Currently all other params passed straight through
func translateParams(_ dictionary:[String:Any]) -> [String:Any] {
  var returnVal = [String:Any]()

  let paramNameTranslation:[String:String] = ["c":"prompt","uc":"negative_prompt"]

  for (key, value) in dictionary {
    if let newKey = paramNameTranslation[key] {
      returnVal[newKey] = value
    } else {
      returnVal[key] = value
    }
  }
  return returnVal
}


// try various methods of extracting metadata.
// 1st choice: EXIF UserComment.
// 2d choice - TIFF ImageDescription
func getEmbeddedParamString(_ url: URL) -> String? {
  guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
    print("Error: Could not create image source from url")
    return nil
  }
  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0,nil) as? [String: Any]

  // try to get exif 1st

  if let exifProperties = properties?[kCGImagePropertyExifDictionary as String] as? [String: Any],
     let jsonString = exifProperties["UserComment"] as? String {

    return jsonString
  }
  else {
    guard let pngProperties = properties?[kCGImagePropertyTIFFDictionary as String] as? [String: Any] else {
      print("Error: Could not get PNG properties")
      return nil
    }
    return pngProperties["ImageDescription"] as? String
  }
}

func JsonStringtoDict(_ string:String) -> [String:Any]?{
  do{
    if let dictionary = try JSONSerialization.jsonObject(with: string.data(using: .utf8)!,
                                                         options: []) as? [String: Any] {
      return dictionary
    }
  }
  catch{}
  return nil
}


/// extract prompt, neg prompt, & params. straightup json. NO translation, or filtering
func announceDescriptionString(_ desc:String, _ channel:Messageable) {
  let promptOnly = exifbotState.botState == .promptOnlyMode

  let negPrefix = "\n-"
  var textBlocks:[String.SubSequence]
  let posPrompt:String
  let negPrompt:String
  var params:String

  var sayString = "I found image data:"
  if promptOnly { sayString.append(" (showing prompts only)")}
  say(sayString,channel)
  sayString = ""

  if desc.contains(negPrefix) {
    textBlocks = desc.split(separator: negPrefix)

    if textBlocks.count < 2 {
      return
    }

    posPrompt = String(textBlocks[0]).trimmingCharacters(in: .whitespacesAndNewlines)
    textBlocks = textBlocks[1].split(separator: "\n")

    let lineCount = textBlocks.count
    if lineCount > 2 {
      negPrompt = textBlocks[0...textBlocks.count-2].joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    else {
      negPrompt = String(textBlocks[0]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
  }
  else {  //  no neg prompt. treat it as posPrompt ...\r params - could be multiple newlines
    textBlocks = desc.split(separator: "\n")
    let lineCount = textBlocks.count
    if lineCount > 2 {
      posPrompt = textBlocks[0...textBlocks.count-2].joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    else {
      posPrompt = String(textBlocks[0]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    negPrompt = ""
  }
  sayString.append("Prompt: \(posPrompt)\n")
  sayString.append("Negative Prompt: \(negPrompt.isEmpty ? "<none>" : negPrompt)\n ")

  if !promptOnly {
    params = String(textBlocks.last!)
    let formattedParams = prettyPrintParams(params)

    sayString.append("\(formattedParams)")
    var paramcount = formattedParams.split(separator: "\n").count
    log("posting text block of \(paramcount) params (not counting prompts)")

    if !posPrompt.isEmpty {paramcount += 1 }
    if !negPrompt.isEmpty {paramcount += 1 }
    trackParameterHighScore(paramcount, channel:channel)
  }
  sendAsFile(sayString, channel)

  return
}

// manually format this json, because embedded comma in this one parameter breaks everything:
//  crop: (0,0)
func prettyPrintParams(_ rawText: String) -> String {
    var isInParens = false
    var outString = ""

    var chars = rawText.makeIterator()
    while let char = chars.next() {
        if char == ","  && !isInParens {
          outString.append("\n")
        } else if char == "(" {
            isInParens = true
          outString.append(char)

        } else if char == ")" {
            isInParens = false
          outString.append(char)
        } else {
          outString.append(char)
        }
    }
    return outString
}
/// Gamify. Create Engagement.
func trackParameterHighScore(_ score:Int, channel: Messageable) {
  if score > exifbotState.maxParameters {
    exifbotState.maxParameters = score
    log("New Parameter High Score!: \(score)")
    if score > 20 {
      say ("🥳 New Parameter High Score! 🥳: \(score) parameters",channel)
    }
  }
}

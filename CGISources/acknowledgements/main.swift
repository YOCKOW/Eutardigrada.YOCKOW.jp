/* *************************************************************************************************
 main.swift
   © 2025 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */

// You can, of course, put out HTML to the clients.
// While you may want to use other frameworks to build HTML,
// this CGI program has no dependencies for the purpose of illustration.

import Foundation

enum Constant {
  static let licensesDirectory = "/licenses"
  static let licensesMetadataDirectory = "\(licensesDirectory)/metadata"
}

extension UTF8.CodeUnit {
  static let lt: UTF8.CodeUnit = 0x3C
  static let gt: UTF8.CodeUnit = 0x3E
  static let quot: UTF8.CodeUnit = 0x22
  static let apos: UTF8.CodeUnit = 0x27
  static let amp: UTF8.CodeUnit = 0x26
}

extension String {
  var ampersandEscaped: String {
    var resultUTF8 = Data()
    for byte in self.utf8 {
      switch byte {
      case .lt: resultUTF8.append(contentsOf: "&lt;".utf8)
      case .gt: resultUTF8.append(contentsOf: "&gt;".utf8)
      case .quot: resultUTF8.append(contentsOf: "&quot;".utf8)
      case .apos: resultUTF8.append(contentsOf: "&apos;".utf8)
      case .amp: resultUTF8.append(contentsOf: "&amp;".utf8)
      default: resultUTF8.append(byte)
      }
    }
    return String(data: resultUTF8, encoding: .utf8)!
  }
}

struct LicenseMetadata: Decodable {
  static var licensesDirectory = Constant.licensesDirectory

  let name: String
  let url: String?
  let version: String?
  let filenames: [String: String]
  let fileOrder: [String]?

  enum Key: String, CodingKey {
    case name
    case url
    case version
    case filenames
    case fileOrder = "file_order"
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.url = try container.decodeIfPresent(String.self, forKey: .url)
    self.version = try container.decodeIfPresent(String.self, forKey: .version)
    self.filenames = try container.decode(Dictionary<String, String>.self, forKey: .filenames)
    self.fileOrder = try container.decodeIfPresent(Array<String>.self, forKey: .fileOrder)
  }

  var html: String {
    get throws {
      var result = #"<details open="open" class="license-group">"#
      GENERATE_HTML: do {
        defer { result += "</details>" }

        // Software Name
        SOFTWARE_NAME: do {
          result += #"<summary class="software-name">"#
          defer { result += "</summary>" }

          url.map { result += #"<a href="\#($0.ampersandEscaped)">"# }
          result += name.ampersandEscaped
          url.map { _ in result += "</a>" }
          if let version = self.version, version != "", version != "unspecified" {
            result += " (ver. \(version))"
          }
        }

        // Each License
        let fileOrder: [String] = self.fileOrder ?? self.filenames.keys.sorted()
        for originalFilename in fileOrder {
          guard let filename = self.filenames[originalFilename] else {
            fatalError(#"Missing filename for "\#(originalFilename)"?! (Software Name: \#(name))"#)
          }
          let license = try String(contentsOfFile: "\(Self.licensesDirectory)/\(filename)", encoding: .utf8)

          result += #"<details open="open" class="each-license">"#
          defer { result += "</details>" }

          result += #"<summary class="filename">\#(originalFilename.ampersandEscaped)</summary>"#

          PRE_LICENSE: do {
            result += #"<pre class="license">"#
            defer { result += "</pre>" }

            if filename.hasSuffix(".html") {
              result += license
            } else {
              result += license.ampersandEscaped
            }
          }
        }
      }
      return result
    }
  }

  static func collect() throws -> [LicenseMetadata] {
    let fileManager = FileManager.default
    let files = try fileManager.contentsOfDirectory(atPath: Constant.licensesMetadataDirectory)
    let decoder = JSONDecoder()
    var result: [LicenseMetadata] = []
    for file in files.filter({ $0.hasSuffix(".json") }).sorted() {
      let metadata = try decoder.decode(
        LicenseMetadata.self,
        from: Data(
          contentsOf: URL(fileURLWithPath: "\(Constant.licensesMetadataDirectory)/\(file)")
        )
      )
      result.append(metadata)
    }
    return result
  }
}


print("""
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
  <head>
    <title>Acknowledgements - Eutardigrada.YOCKOW.jp</title>
    <style>
      h1, details.license-group {
        margin: 2em auto;
        max-width: 80%;
      }
      summary.software-name {
        width:100%;
        padding: 1.5em;
        border-width: 1px;
        border-style: dashed none;
        border-color: green;
      }
      summary.filename {
        margin: 1em;
        padding: 1em;
        border-width: 1px;
        border-style: none none dotted none;
        border-color: green;
        list-style-type: none;
        cursor: pointer;
      }
      summary.filename::-webkit-details-marker {
        display: none;
      }
      summary.filename::before {
        content: "\\1F4C4 ";
      }
    </style>
  </head>
  <body>
    <h1>Acknowledgements - Eutardigrada.YOCKOW.jp</h1>

""")

defer {
  print("""

    </body>
  </html>
  """)
}


for metadata in try LicenseMetadata.collect() {
  print(try metadata.html)
}
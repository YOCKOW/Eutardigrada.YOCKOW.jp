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

print("""
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
  <head>
    <title>Acknowledgements - Eutardigrada.YOCKOW.jp</title>
    <style>
      h1, details {
        margin: 2em auto;
        max-width: 80%;
      }
      summary {
        width:100%;
        padding: 1.5em;
        border-width: 1px;
        border-style: dashed none;
        border-color: green;
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

let fileManager = FileManager.default
let licensesDir = "/licenses"
let licenseFiles = try fileManager.contentsOfDirectory(atPath: licensesDir)
for licenseFilename in licenseFiles.sorted() where !licenseFilename.hasPrefix(".") {
  let licenseFileAbsPath = "\(licensesDir)/\(licenseFilename)"
  let license = try String(contentsOfFile: licenseFileAbsPath, encoding: .utf8)

  print(#"<details open="open">"#)
  defer { print("</details>") }

  print("<summary>")
  printAmpersandEscapedString(licenseFilename)
  print("</summary>")
  
  print("<pre>")
  if licenseFilename.hasSuffix(".html") {
    print(license)
  } else {
    printAmpersandEscapedString(license)
  }
  print("</pre>")
}


func printAmpersandEscapedString(_ string: String) {
  for scalar in string.unicodeScalars {
    switch scalar {
    case "<":
      print("&lt;", terminator: "")
    case ">":
      print("&gt;", terminator: "")
    case "\"":
      print("&quot;", terminator: "")
    case "'":
      print("&apos;", terminator: "")
    case "&":
      print("&amp;", terminator: "")
    default:
      print(scalar, terminator: "")
    }
  }
  print("")
}

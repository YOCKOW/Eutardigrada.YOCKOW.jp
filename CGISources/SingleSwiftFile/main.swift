/* *************************************************************************************************
 main.swift
   © 2025 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */

// All the output for CGI needs is 'Content-Type:' line.
//
// Any newlines in CGI header will be translated to `CR+LF` for HTTP header by the server.
// https://datatracker.ietf.org/doc/html/rfc3875#section-6.3.4

print("""
Content-Type: text/plain; charset=UTF-8

Hello, Swift CGI World!
""")
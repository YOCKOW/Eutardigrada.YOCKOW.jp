# What's this repository?

This is a sample repository illustrating how to use [DockerSwiftApacheCombination](https://GitHub.com/YOCKOW/DockerSwiftApacheCombination).


# Feel nostalgic; Touch legacy techniques through Swift.

First of all, you should use reliable frameworks such as [Vapor](https://vapor.codes/) if you want to build commercial-grade web products.

On the other hand, you can enjoy Swift programming to build your personal web site by writing CGI programs in Swift. [DockerSwiftApacheCombination](https://GitHub.com/YOCKOW/DockerSwiftApacheCombination) may make it easier to deploy such web services.

For what it's worth, all CGI programs for [the personal web site of the author of this repository](https://YOCKOW.jp/) are written in Swift.

## How to write

It's very simple to write CGI programs in Swift:

```Swift
// All the output for CGI needs is 'Content-Type:' line.
//
// Any newlines in CGI header are translated to `CR+LF` for HTTP header by the server.
// See https://datatracker.ietf.org/doc/html/rfc3875#section-6.3.4

print("""
Content-Type: text/plain; charset=UTF-8

Hello, Swift CGI World!
""")
```

You can see the actual results:

| Result                                                                         | Source                                                                                                                                 |
|--------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| [/single-swift-file.cgi](https://eutardigrada.yockow.jp/single-swift-file.cgi) | [./CGISources/SingleSwiftFile/main.swift](./CGISources/SingleSwiftFile/main.swift)                                                     |
| [/swift-package.cgi](https://eutardigrada.yockow.jp/swift-package.cgi)         | [./CGISources/SwiftCGIPackage/Sources/swift-package.cgi/main.swift](./CGISources/SwiftCGIPackage/Sources/swift-package.cgi/main.swift) |

(They run on an experimental server. The service may be often down.)


## How to deploy

For ease of explanation, this repository contains only one [`Dockerfile`](./Dockerfile) which uses [multi-stage builds](https://docs.docker.com/build/building/multi-stage/). See the content of that `Dockerfile` for more details.

### 1. Compile Swift sources

You can compile Swift sources using a container image such as `swift:6.1.2-noble`.
In this repository, the compiled (executable) files are located at '/home/swifche/Web/CGI' directory where `swifche` is a default user in `DockerSwiftApacheCombination` image.

### 2. Copy executable files

Then, copy the executable files into a `DockerSwiftApacheCombination` image which is, for example, tagged as `ghcr.io/yockow/swift-de-cgi:Swift_6.1.2-noble-latest`.

### 3. Run container image with your `httpd.conf`

Now, let's run the container image like:

`# docker run -it -d --rm -v /path/to/my/web:/home/swifche/web -p 80:80 -p 443:443 my-swift-cgi-image httpd -f /home/swifche/web/httpd.conf`

[Docker compose](https://docs.docker.com/compose/) is, of course, available to run the container image.
This container also contains `docker-compose.*.yml` files. Please refer to them.

You can also see a sample [`httpd.conf`](./Web/Config/httpd.conf) in this repository.


# License

MIT License.  
See "LICENSE.txt" for more information.

## Caveat

Whereas this repository itself and `DockerSwiftApacheCombination` are licensed under MIT License, the deployed container image contains some other open source softwares.
Their license files are in the directory at `/licenses` and you can see them by executing `show-licenses` in the container.

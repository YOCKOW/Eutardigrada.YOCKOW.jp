################################################################################
#
# Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG SWIFT_COMPILER_IMAGE="swift:6.1.2-noble"
ARG SWIFT_DE_CGI_IMAGE="ghcr.io/yockow/swift-de-cgi:Swift_6.1.2-noble-release-20250819-080511"
ARG CGI_DERIVATIVES_DIR="/home/swifche/Web/CGI"

################################################################################
FROM ${SWIFT_COMPILER_IMAGE} AS swift-cgi-builder

ARG CGI_DERIVATIVES_DIR="/home/swifche/Web/CGI"

RUN mkdir -p "${CGI_DERIVATIVES_DIR}"
COPY ./CGISources /CGISources

# Compile the single Swift file
RUN swiftc -O /CGISources/SingleSwiftFile/main.swift -o "${CGI_DERIVATIVES_DIR}/single-swift-file.cgi"

# Compile Swift Package
WORKDIR /CGISources/SwiftCGIPackage
RUN mkdir -p "${CGI_DERIVATIVES_DIR}/SwiftCGIPackage" \
    && swift build --configuration debug \
    && swift test --configuration debug \
    && swift build --configuration release \
    && cp -R "$(cd .build/release/ && pwd -P)" "${CGI_DERIVATIVES_DIR}/SwiftCGIPackage/"


################################################################################
FROM ${SWIFT_DE_CGI_IMAGE}

ARG CGI_DERIVATIVES_DIR
COPY --from=swift-cgi-builder "${CGI_DERIVATIVES_DIR}" "${CGI_DERIVATIVES_DIR}"

STOPSIGNAL SIGWINCH
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint"]

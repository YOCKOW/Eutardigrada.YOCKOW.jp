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
ARG SWIFT_VERSION="6.1.2"
ARG OS_NICKNAME="noble"
ARG SWIFT_COMPILER_IMAGE="swift:${SWIFT_VERSION}-${OS_NICKNAME}"
ARG SWIFT_DE_CGI_IMAGE="ghcr.io/yockow/swift-de-cgi:Swift_${SWIFT_VERSION}-${OS_NICKNAME}-latest"
ARG WEB_ROOT="/home/swifche/Web"
ARG CGI_DERIVATIVES_DIR_RELATIVE_PATH="static/CGI"
ARG CGI_DERIVATIVES_DIR="${WEB_ROOT}/${CGI_DERIVATIVES_DIR_RELATIVE_PATH}"

################################################################################
FROM ${SWIFT_COMPILER_IMAGE} AS swift-cgi-builder

ARG CGI_DERIVATIVES_DIR

RUN mkdir -p "${CGI_DERIVATIVES_DIR}"
COPY ./CGISources /CGISources

# Compile the single Swift file
RUN swiftc -O /CGISources/SingleSwiftFile/main.swift -o "${CGI_DERIVATIVES_DIR}/single-swift-file.cgi"

# Compile Swift Package
COPY ./.swift-scratch /swift-scratch
WORKDIR /CGISources/SwiftCGIPackage
RUN mkdir -p "${CGI_DERIVATIVES_DIR}/SwiftCGIPackage" \
    && swift build --configuration release --scratch-path /swift-scratch \
    && cp -R "$(cd /swift-scratch/release/ && pwd -P)" "${CGI_DERIVATIVES_DIR}/SwiftCGIPackage/"

################################################################################
FROM ${SWIFT_DE_CGI_IMAGE}

ARG WEB_ROOT
ARG CGI_DERIVATIVES_DIR

COPY "./Web/static" "${WEB_ROOT}/static"
COPY --from=swift-cgi-builder "${CGI_DERIVATIVES_DIR}" "${CGI_DERIVATIVES_DIR}"

STOPSIGNAL SIGWINCH
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint"]

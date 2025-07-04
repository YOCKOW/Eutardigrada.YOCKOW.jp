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
ARG SWIFT_DE_CGI_IMAGE="ghcr.io/yockow/swift-de-cgi:Swift_6.1.2-noble-release-20250701-074931"

################################################################################
FROM ${SWIFT_DE_CGI_IMAGE}

STOPSIGNAL SIGWINCH
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint"]

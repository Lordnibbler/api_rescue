# Represents a generic template for any sort of errors. Should look like:
#
#   {
#     "error": "brief details",
#     "details": "An optional, human-readable description of this error",
#     "code": "token_expired"
#   }
#
#
# Usage:
#
#   jbuilder.partial! 'api_rescue/error',
#     message: 'brief details',
#     details: 'An optional human-readable...'

json.error message
json.code error_code if defined?(error_code) && error_code.present?
json.details details if defined?(details) && details.present?

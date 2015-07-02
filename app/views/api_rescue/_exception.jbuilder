# Renders any exception using our default convention:
#
#   {
#     "error": "message provided in exception",
#     "exception": {
#       "message": "foo",
#       "class_name": "RuntimeError",
#       "backtrace": [
#         "foo": "bar"
#       ]
#     }
#   }
#
#
# Usage:
#
#   render partial: 'api_rescue/exception', locals: { exception: exception }, status: :not_found
#

json.partial! 'api_rescue/error', message: exception.to_s
json.exception do
  json.partial! 'api_rescue/exception_details', exception: exception
end

# Displays validation errors
#
#  {
#     "error": "submission invalid",
#     "details": "The data you submitted is invalid. Please review...",
#     "validation": {
#       "device": ["can't be blank"]
#     },
#     "exception": {
#       # backtrace and more
#     }
# }
#

json.partial! 'api_rescue/error',
  message: 'submission invalid',
  details: 'The data you submitted is invalid. Please review the errors and try again'

json.validation exception.record.errors

json.partial! 'api_rescue/exception', exception: exception

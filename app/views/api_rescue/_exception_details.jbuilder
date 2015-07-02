# Renders details about an exception
#
#   {
#     "message": "foo",
#     "class_name": "RuntimeError",
#     "backtrace": [
#       "foo": "bar"
#     ],
# }
#

json.message exception.to_s
json.class_name exception.class.name

if ApiRescue.include_error_backtrace?
  json.backtrace ApiRescue.backtrace_cleaner.clean(exception.backtrace)

  if exception.cause
    json.cause do
      json.partial! 'api_rescue/exception_details', exception: exception.cause
    end
  end
end

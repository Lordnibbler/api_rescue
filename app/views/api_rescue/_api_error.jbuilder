# Same as _exception.jbuilder, but made specifically for the ApiRescue::ApiError class

json.partial! 'api_rescue/error',
  message: exception.to_s,
  error_code: exception.code,
  details: exception.details

json.exception do
  json.partial! 'api_rescue/exception_details', exception: exception
end

require 'api_rescue/engine'
require 'jbuilder'

#
# Enables DRY controllers by automatically rescuing from common errors
# (i.e. ActiveRecord::ExceptionNotFound).
# Also provides a handy {#error} method to send errors (i.e. unexpected conditions) to the end user.
#
module ApiRescue
  extend ActiveSupport::Concern

  # Generic API error
  class ApiError < Exception
    # The http status (i.e. '200' or :unauthorized) that should be returned
    attr_accessor :status

    # API error code
    attr_accessor :code

    # Human-readable description
    attr_accessor :details

    def initialize(message, status: 500, code: nil, details: nil)
      super(message)
      @status  = status
      @code    = code
      @details = details
    end

    def status
      @status || :internal_server_error
    end
  end

  #
  # automatically rescue from specified errors
  #
  module ClassMethods
    # Allows you to rescue one or more classes with a specific code
    # @example
    #   rescue_default MyException, AnotherException, status: :not_found
    def rescue_default(*klasses)
      options = klasses.extract_options!
      rescue_from(*klasses) do |e|
        log.error e if defined?(log)
        render({ partial: 'api_rescue/exception', locals: { exception: e } }.deep_merge(options))
      end
    end
  end

  # classes that include this module will inherit these rescue calls
  included do
    ## DEFAULT RESCUERS
    # Lowest priority to highest
    rescue_default Exception, status: :internal_server_error
    rescue_default ActiveRecord::RecordNotFound, status: :not_found
    rescue_default ActiveRecord::RecordInvalid,  status: :unprocessable_entity

    rescue_from ActiveRecord::RecordInvalid, with: :rescue_record_invalid
    rescue_from ApiError, with: :rescue_api_error
  end

  #
  # Easy way to raise an error to the end API user
  #
  # @example Basic Usage
  #   def some_method
  #     # ... something
  #     error 'Some condition happened' unless some_thing?
  #   end
  #
  # @example Exception Handling
  #   def some_action
  #     # Some Code ...
  #   rescue Exception => e
  #     # Backtrace of `e` will also be included when calling error()
  #     error 'This case should not have happened'
  #   end
  #
  # @example Change Response Status
  #   def some_action
  #     error 'User not authorized', status: :unauthorized unless @user.authorized?
  #   end
  #
  # @example Error Codes
  #   error 'Token Expired', status: :unauthorized, code: 'token_expired'
  #
  def error(message, status: 500, code: nil, details: nil)
    exception = ApiError.new message, status: status, code: code, details: details
    fail exception
  end

  private

  def self.backtrace_cleaner
    @_backtrace_cleaner ||= begin
      bc = ActiveSupport::BacktraceCleaner.new
      bc.add_filter { |line| line.gsub(Rails.root.to_s + '/', '') }
      bc
    end
  end

  def self.include_error_backtrace?
    true
  end

  # @param exception [ActiveRecord::RecordInvalid] the error
  def rescue_record_invalid(exception)
    log.error exception if defined?(log)
    render partial: 'api_rescue/record_invalid',
           locals: { exception: exception },
           status: :unprocessable_entity
  end

  # Handles rescuing of an api error from the {#error} method
  def rescue_api_error(exception)
    if defined?(log)
      log.error "ERROR: #{exception.status} #{exception.code} | #{exception.message} " \
        ": #{exception.details}"
      log.error exception
    end

    render partial: 'api_rescue/api_error',
           locals: { exception: exception },
           status: exception.status
  end
end

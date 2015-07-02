class TestController < ApplicationController
  include ApiRescue

  # Generic exception that should test many edge cases
  def index
    fail ArgumentError, 'This is an exception'
  rescue StandardError
    raise 'Caught the exception'
  end
end

require 'test_helper'
require 'jbuilder'

class ApiRescueTest < ActiveSupport::TestCase
  test 'smoke test' do
    assert_kind_of Module, ApiRescue
  end
end

class TestControllerTest < ActionController::TestCase
  test 'it renders the error message with the correct status code' do
    get :index
    assert_response 500
    assert_equal(json[:error], 'Caught the exception')
  end
end

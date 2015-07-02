# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../test/dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/pride'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActiveSupport::TestCase.fixtures :all
end


# Returns the parsed JSON wrapped in StrongParameters
def json
  if response.content_type == 'application/json'
    @last_json = JSONParams.new(JSON.parse(response.body)) if @last_body != response.body
    @last_body = response.body
    return @last_json
  end
  fail 'Response did not return an application/json type!'
end

# Makes testing JSON easy!
#
# Say you expect a JSON response:
#
#     {
#       user: {
#         first_name: 'Whatever',
#         last_name: 'Smith'
#       }
#     }
#
# You can now do:
#
#   json.require :user do |u|
#     u[:first_name].should be_a(String)
#     u[:last_name].should be_a(String)
#   end
#
# Or, another shorthand:
#
#   json.require(:user).requires(first_name: String, last_name: String)
#
# Or, if you don't care about the types:
#
#   json.require(:user).requires(:first_name, :last_name)
#
# Note that `attribute: null` will fail the require assertion
class JSONParams < ActionController::Parameters
  def require(key)
    result = super(key)
    yield self[key] if block_given?
    return result
  rescue ActionController::ParameterMissing
    raise RSpec::Expectations::ExpectationNotMetError,
          "Expected JSON parameter '#{key}' not found or nil"
  end

  def requires(*args)
    hsh = args.extract_options!
    args.each { |arg| hsh[arg] = nil }
    hsh.each do |key, klass|
      require(key)
      if klass.is_a?(Class) && !(self[key].is_a? klass)
        fail RSpec::Expectations::ExpectationNotMetError,
             "Expected JSON parameter '#{key}' to be of type
              '#{klass}', but was of type '#{self[key].class.name}'"
      end
    end
  end

  #
  # Ensures that a segment of JSON looks like a given model
  # @param [ActiveRecord::Base] model a rails model
  # @param [Hash] args
  # @option args [Array,Symbol] :include a list of attributes or methods that appear in the JSON
  #   response, but are not model attributes (such as a model method)
  # @option args [Array,Symbol] :exclude a list of attributes that do not appear in the JSON
  #   response, but are model attributes
  # @option args [Array,Symbol] :only whitelists attributes that should be checked
  # @option args [Array,Symbol] :ignore blacklists attributes. Useful if you have a JSON key
  #   that does not map directly to a model attribute or method.
  # @example Sample Response
  #   # Note "url" is not included in the response JSON
  #   {
  #     "resource_server": {
  #       "id": 1234,
  #       ....,
  #       "secret_key": "1234:some-key"
  #     }
  #   }
  #
  # @example Sample Validation
  #   my_json[:resource_server]
  #     .should_look_like ResourceServer.last, include: :secret_key, except: :url
  #
  def should_look_like(model, *args)
    opts = args.extract_options!
    exclude = Array.wrap(opts[:exclude]) | Array.wrap(opts[:except])
    include = Array.wrap(opts[:include])
    only    = Array.wrap(opts[:only]).map(&:to_s)
    ignore  = Array.wrap(opts[:ignore]).map(&:to_s)

    expected = model.attributes.stringify_keys.except(*ignore).except(*exclude)

    expected.delete_if { |k| !only.include?(k) } if only.any?

    # Other things, such as method calls
    include.each do |inclusion|
      expected[inclusion] = model.send(inclusion)
    end

    expected = JSON.parse(expected.to_json) # Handle cases of unusual values, i.e. DateTime)
    actual   = to_hash.except(*ignore)

    missing_keys = expected.keys - actual.keys
    if missing_keys.any?
      fail RSpec::Expectations::ExpectationNotMetError,
           "Actual JSON does not contain expected keys: #{missing_keys.join ', '}"
    end

    extra_keys = actual.keys - expected.keys
    if extra_keys.any?
      fail RSpec::Expectations::ExpectationNotMetError,
           "Actual JSON contains unexpected keys: #{extra_keys.join ', '}"
    end

    fail RSpec::Expectations::ExpectationNotMetError,
         "Expected response json to look like:\n
         #{JSON.pretty_generate(expected)}\n
      instead, got\n
         #{self}" unless expected == actual
  end

  # Gets a pretty printed JSON version
  def to_s
    JSON.pretty_generate to_hash
  end
end

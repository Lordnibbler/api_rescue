[![Build Status](https://travis-ci.org/Lordnibbler/api_rescue.svg?branch=master)](https://travis-ci.org/Lordnibbler/api_rescue)

# ApiRescue

This is a gem designed to be used in a Rails 4.x application which contains APIs. It enables DRY, simple controllers leveraging `ActiveRecord`'s `!` methods by automatically rescuing from common errors, i.e. `ActiveRecord::RecordNotFound`.  Also provides a handy `#error` method to send errors (i.e. unexpected conditions) to the end user.

## Installation & Usage

1. Add the gem to your `Gemfile`

    ```ruby
    gem 'api_rescue', github: 'lordnibbler/api_rescue'
    ```

2. Run `bundle`
3. Mix in the gem to an `ActionController::Base` class
  ```ruby
  class FooController < ActionController::Base
    include ApiRescue

    def index
      # your code...
    end
  end
  ```

### DRY Controller Methods
Now, your controller methods can go from this:

  ```ruby
  def update
    @user = User.find!(user_params.require(:id))
    @user.update_attributes!(user_params)
  rescue ActiveRecord::RecordNotFound => e
    # error handling code
  rescue ActiveRecord::RecordInvalid => e
    # more error handling code
  rescue StandardError => e
    # even more error handling code
  end
  ```

  to this

  ```ruby
  def update
    @user = User.find!(params[:id])
    @user.update_attributes!(params[:user])
  end
  ```

### `error()` method

Any controller that mixes in `ApiRescue` can invoke a call to the `error()` method. This method will instantiate a new `ApiError` exception, and `raise` it, thus invoking the `rescue_from ApiError` logic in this gem.

The `error()` method accepts several params as [documented in the source](lib/api_rescue.rb).

Example request/response:

```ruby
# invoking error in your controller
error(
  'Hello World',
  status: 404,
  code: 'hello_world_not_found',
  details: 'Hello. The world was not found.'
)

# builds a JSON response (represented as a Ruby Hash here):
{
  "error" => "hello world",
  "code" => "hello_world_not_found",
  "details" => "The hello world was not found. please try again.",
  "exception" => {
    "message" => "hello world",
    "class_name" => "ApiRescue::ApiError",
    "backtrace" => [
      "/Users/turtle/Code/gems/api_rescue/lib/api_rescue.rb:95:in `error'",
      # ...
    ]
  }
}
```

### Overriding Views

You can override any of this gem's [default views](app/views/api_rescue) by copying these views to your `/app/views/api_rescue` directory in your Rails application.

## License
This project rocks and uses MIT-LICENSE.

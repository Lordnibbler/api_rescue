# ApiRescue

This is a gem designed to be used in a Rails 4.x application. It enables DRY, simple controllers leveraging `ActiveRecord`'s `!` methods by automatically rescuing from common errors, i.e. `ActiveRecord::RecordNotFound`.  Also provides a handy `#error` method to send errors (i.e. unexpected conditions) to the end user.

## Installation & Usage

1. Add the gem to your `Gemfile`

    ```ruby
    gem 'api_rescue'
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

4. Now, your controller methods can go from this:

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

## License
This project rocks and uses MIT-LICENSE.

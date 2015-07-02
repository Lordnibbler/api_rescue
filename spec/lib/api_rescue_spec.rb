require 'api_helper'

describe ApiRescue, type: :controller do
  controller do
    include ApiRescue

    # generic exception that tests most cases
    def index
      fail ArgumentError, 'This is an exception'
    rescue StandardError
      raise 'Caught the exception'
    end
  end

  # We use rescue_default with the Exception class
  describe '.rescue_default' do
    it 'renders the error message with the correct status code' do
      get :index

      expect(json[:error]).to eq('Caught the exception')
      expect(response.code.to_i).to eq(500)
    end

    it 'displays the backtrace with cause' do
      get :index
      expect(json[:exception]).to be_present
      expect(json[:exception][:backtrace]).to be_an(Array)
      expect(json[:exception][:cause]).to be_present
      expect(json[:exception][:cause][:message]).to eq('This is an exception')
    end
  end

  describe '#error' do
    it 'raises an ApiError with an error message' do
      expect {
        controller.send(:error, 'some message')
      }.to raise_error(ApiRescue::ApiError, 'some message')
    end

    it 'raises an ApiError with an error code' do
      begin
        controller.send(:error, 'some message', status: 404)
      rescue ApiRescue::ApiError => e
        expect(e.status).to eq(404)
      end
    end
  end

  describe '#rescue_api_error' do
    controller do
      include ApiRescue
      def index
        error(
          'hello world',
          status: 404,
          code: 'hello_world_not_found',
          details: 'The hello world was not found. please try again.'
        )
      end
    end

    it 'returns the correct status code' do
      get :index
      expect(response.status.to_i).to eq(404)
    end

    it 'displays the correct error' do
      get :index
      expect(json[:error]).to eq('hello world')
    end

    it 'returns the exception details' do
      get :index
      expect(json[:exception]).to be_present
    end

    it 'returns the code' do
      get :index
      expect(json[:code]).to eql('hello_world_not_found')
    end

    it 'returns details' do
      get :index
      expect(json[:details]).to eql('The hello world was not found. please try again.')
    end
  end

  describe '#rescue_record_invalid' do
    controller do
      include ApiRescue
      def index
        User.create!
      end
    end

    before do
      @user = User.new
      @user.valid?
      @errors = @user.errors
    end

    it 'returns an unprocessable entity' do
      get :index
      expect(response.code.to_i).to eq(422)
    end

    it 'displays a "validation" key' do
      get :index
      expect(json[:error]).to start_with('Validation failed:')
      expect(json[:details]).to start_with('The data you submitted is invalid.')
      expect(json[:validation]).to be_a(Hash)
      expect(json[:validation]).to eq(@errors.messages.stringify_keys)
    end
  end
end

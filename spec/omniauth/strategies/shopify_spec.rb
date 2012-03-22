ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'omniauth-shopify'
require 'digest/md5'

include Rack::Test::Methods

describe OmniAuth::Strategies::Shopify do
  def app
    Rack::Builder.new {
      use Rack::Session::Cookie
      use OmniAuth::Strategies::Shopify, 'apikey', 'hush'
      run lambda {|env| [404, {'Content-Type' => 'text/plain'}, [nil || env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def query_parameters
    {
      "shop" => "some-shop.myshopify.com",
      "t" => "a94a110d86d2452eb3e2af4cfb8a3828"
    }
  end

  def query_string
    query_parameters.collect { |k, v| "#{k}=#{v}" }.join '&'
  end

  def timestamp
    Time.now.utc.to_i
  end

  def bad_timestamp
    (Time.now - 25 * 3600).utc.to_i
  end

  def signature timestamp
    calculated_signature = query_parameters.collect { |k, v| "#{k}=#{v}" }
    calculated_signature.push "timestamp=#{timestamp}"
    Digest::MD5.hexdigest('hush' + calculated_signature.sort.join)
  end

  def password
    Digest::MD5.hexdigest('hush' + query_parameters['t'])
  end

  describe '#request_phase' do
    it 'must prompt for a shop url' do
      get '/auth/shopify'
      last_response.body.must_match %r{<input[^>]*shop}
    end

    it 'must redirect to authentication url' do
      post '/auth/shopify', :shop => 'some-shop'
      assert last_response.redirect?
      last_response.headers['Location'].must_equal 'http://some-shop.myshopify.com/admin/api/auth?api_key=apikey'
    end
  end

  describe '#callback phase' do
    before(:each) do
      get "/auth/shopify/callback?#{query_string}&timestamp=#{timestamp}&signature=#{signature(timestamp)}"
    end

    it 'must have auth hash' do
      last_request.env['omniauth.auth'].must_be_kind_of Hash
    end

    it 'must have proper uid' do
      last_request.env['omniauth.auth']['uid'].must_equal 'some-shop'
    end

    it 'must have site URL' do
      last_request.env['omniauth.auth']['info']['urls']['site'].must_equal "https://some-shop.myshopify.com/admin"
    end

    it 'must have username' do
      last_request.env['omniauth.auth']['credentials']['username'].must_equal 'apikey'
    end

    it 'must have password' do
      last_request.env['omniauth.auth']['credentials']['password'].must_equal password
    end
  end

  describe 'invalid response' do
    it 'must fail when bad signature' do
      get "/auth/shopify/callback?#{query_string}&timestamp=#{timestamp}&signature=some_bad_signature"
      last_response.headers['Location'].must_match %r{invalid_response}
    end

    it 'must fail when timestamps above 24 hours' do
      get "/auth/shopify/callback?#{query_string}&timestamp=#{bad_timestamp}&signature=#{signature(bad_timestamp)}"
      last_response.headers['Location'].must_match %r{invalid_response}
    end
  end
end

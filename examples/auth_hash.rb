$:.push File.dirname(__FILE__) + '/../lib'

require 'sinatra'
require 'omniauth-shopify'

use Rack::Session::Cookie
use OmniAuth::Strategies::Shopify, ENV['SHOPIFY_KEY'], ENV['SHOPIFY_SECRET']

get '/' do
  <<-HTML
  <ul>
    <li><a href='/auth/shopify'>Sign in with Shopify</a></li>
  </ul>
  HTML
end

get '/auth/shopify/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].inspect
end

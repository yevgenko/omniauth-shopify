$:.push File.dirname(__FILE__) + '/../lib'

require 'sinatra'
require 'omniauth-shopify'
require 'httparty'

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
  url = request.env['omniauth.auth']['info']['urls']['site']
  credentials = request.env['omniauth.auth']['credentials']
  HTTParty.get("#{url}/orders.json?limit=5", :basic_auth => credentials, :headers => { 'ContentType' => 'application/json' }).inspect
end
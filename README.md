# OmniAuth Shopify Strategy

Strategy for authenticating to Shopify API using OmniAuth.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-shopify'
```

## Usage

First, you will need to [register an application](http://www.shopify.com/partners/apps) with Shopify and obtain an API key. Once you do that, you can use it like so:

```ruby
use OmniAuth::Builder do
  provider :shopify, 'api_key', 'shared_secret'
end
```

## Auth Hash Schema

The following information is provided back to you for this provider:

```ruby
{
  uid: 'example.myshopify.com',
  info: {
    name: 'example.myshopify.com',
  },
  credentials: {
    token: 'thetoken' # can be used to auth to the API
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

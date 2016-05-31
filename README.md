# OmniAuth Shopify Strategy

Strategy for authenticating to Shopify API using OmniAuth.

[![Build Status](https://secure.travis-ci.org/yevgenko/omniauth-shopify.png)](http://travis-ci.org/yevgenko/omniauth-shopify)

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
  uid: 'some-store',
  info: {
    name: 'some-store',
    urls: { site: 'https://some-store.myshopify.com/admin' }
  },
  credentials: { # basic auth
    username: 'api_key',
    password: 'password'
  }
}
```

## Examples

[examples/][] directory contains few simple [sinatra][] apps:

* auth_hash.rb - displays auth hash schema
* api_consumer.rb - consuming api with [httparty][]

So, make sure you have [sinatra][] and [httparty][] gems and run it as follow:

    SHOPIFY_KEY="apikey" SHOPIFY_SECRET="secret" ruby auth_hash.rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[examples/]:https://github.com/yevgenko/omniauth-shopify/tree/master/examples
[sinatra]:http://www.sinatrarb.com/
[httparty]:https://github.com/jnunemaker/httparty

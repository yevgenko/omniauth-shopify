# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-shopify/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-shopify"
  s.version     = Omniauth::Shopify::VERSION
  s.authors     = ["Yevgeniy A. Viktorov"]
  s.email       = ["craftsman@yevgenko.me"]
  s.homepage    = ""
  s.summary     = %q{Shopify strategy for OmniAuth}
  s.description = %q{Strategy for authenticating to Shopify API with OmniAuth.}

  s.rubyforge_project = "omniauth-shopify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'omniauth', '~> 1.0'
end

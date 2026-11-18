require_relative "lib/wulin_oauth/version"

Gem::Specification.new do |s|
  s.name = "wulin_oauth"
  s.version = WulinOAuth::VERSION
  s.authors = ["Ekohe"]
  s.email = ["dev@ekohe.com"]
  s.homepage = "https://gitlab.ekohe.com/ekohe/wulin/wulin_oauth"
  s.summary = "OAuth sign-in for wulin_master apps"
  s.description = "Rails engine that signs users in through an OAuth provider (mima) and manages users through its API."
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.4"

  s.add_dependency "rails", ">= 8.1"
  s.add_dependency "haml"
  s.add_dependency "haml-rails"
  s.add_dependency "httparty"
end

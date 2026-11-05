# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "wulin_oauth/version"

Gem::Specification.new do |s|
  s.name = "wulin_oauth"
  s.version = WulinOAuth::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ekohe"]
  s.email = ["team@ekohe.com"]
  s.homepage = "https://gitlab.ekohe.com/ekohe/wulin/wulin_oauth"
  s.summary = "OAuth sign-in for Wulin Master apps"
  s.description = "Signs users in through an OAuth provider (mima) and manages them there, " \
                  "as the alternative to wulin_auth."
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.executables = []
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.4"

  s.add_dependency "haml-rails"
  s.add_dependency "httparty"
  s.add_dependency "rails", ">= 8.1"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "standardrb"
end

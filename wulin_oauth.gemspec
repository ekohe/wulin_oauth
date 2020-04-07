# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wulin_oauth/version"

Gem::Specification.new do |s|
  s.name        = "wulin_oauth"
  s.version     = WulinOAuth::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ekohe"]
  s.email       = ["team@ekohe.com"]
  s.homepage    = "http://rubygems.org/gems/wulin_oauth"
  s.summary     = "Authentication module for wulin_master"
  s.description = "This gem provides a Oauth authentication interface."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'haml'
  s.add_dependency 'haml-rails'
  s.add_dependency 'httparty'
end



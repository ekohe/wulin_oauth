require 'rake'
require 'rake/testtask'

task :default => :test

desc "Test the wulin_oauth gem"
Rake::TestTask.new("test") { |t|
  t.libs << 'app'
  t.libs << 'lib'
  t.libs << 'config'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
}
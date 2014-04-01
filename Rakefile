begin
  require 'bundler/setup'
rescue LoadError
  fail 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidatesIpAddress'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

desc 'Run RSpec specs'
task :spec do
  ARGV.delete 'spec'
  sh "bundle exec rspec #{ARGV.join ' '}"
end

task default: :spec

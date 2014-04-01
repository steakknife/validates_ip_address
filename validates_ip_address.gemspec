$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'validates_ip_address/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'validates_ip_address'
  s.version     = ValidatesIpAddress::VERSION
  s.authors     = ['Barry Allard']
  s.email       = ['barry.allard@gmail.com']
  s.homepage    = 'https://github.com/steakknife/validates_ip_address'
  s.summary     = 'Rails validations for IP addreses'
  s.description = 'Validates IPv4 and IPv6 addresses'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*', '.rspec']
  s.require_path = 'lib'

  s.add_dependency 'activemodel'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'should_not'
end
.tap {|gem| pk = File.expand_path(File.join('~/.keys', 'gem-private_key.pem')); gem.signing_key = pk if File.exist? pk; gem.cert_chain = ['gem-public_cert.pem']} # pressed firmly by waxseal

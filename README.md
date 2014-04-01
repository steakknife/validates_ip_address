
[![Build Status](https://travis-ci.org/steakknife/validates_ip_address.svg)](https://travis-ci.org/steakknife/validates_ip_address)

# ValidatesIpAddress

## Usage

    class Widget
                                                           # somefield can be ...
                                                           # ipv4  ipv6   single address   network
      validates :somefield, ip: true                       #  y     y          y              y
      validates :somefield, ip: { ranges_only: true }      #  y     y          n              y
      validates :somefield, ip: { addresses_only: true }   #  y     y          y              n
      validates :somefield, ip: { ipv4_only: true }        #  y     n          y              y
      validates :somefield, ip: { ipv6_only: true }        #  n     y          y              y
      validates :somefield, ip: { within: '10.0.0.0/8' }   #  y     y          y              y   and must be 10.0.0.0 - 10.255.255.255
      # combine the above if you wish, it will work
    end

## Installation

### Bundler

    gem 'validates_ip_address'

### manually

    curl -L https://raw.githubusercontent.com/steakknife/validates_ip_address/master/gem-public_cert.pem | gem cert --add -
    gem install validates_ip_address -p HighSecurity

## Author

Barry Allard

## License

MIT

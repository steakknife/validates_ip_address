require 'ipaddr'

class IpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    #$stderr.puts "ip validating record=#{record} attribute=#{attribute} value=#{value} options=#{options}"
    ip = IPAddr.new(value)
    rng = ip.to_range
    result = true

    result &=  ip.ipv4?               if options[:ip4_only] == true
    result &=  ip.ipv6?               if options[:ip6_only] == true

    result &=  rng.first != rng.last if options[:ranges_only] == true
    result &=  rng.first == rng.last if options[:addresses_only] == true

    result &=  IPAddr.new(options[:within]).include? ip if options[:within]

    add_error(record, attribute, value) unless result

  rescue IPAddr::InvalidAddressError
    #$stderr.puts 'InvalidAddressError'
    add_error(record, attribute, value)
  rescue IPAddr::AddressFamilyError
    #$stderr.puts 'AddressFamilyError'
    add_error(record, attribute, value)
  end

private
  def error_message
    'is not a valid ' +

    if options.has_key? :ip6_only
     'IPv6 '
    elsif options.has_key? :ip4_only
     'IPv4 '
    else
     'IPv4 or IPv6 '
    end +

    if options.has_key? :range
      'address range' 
    elsif options.has_key? :address
      'address' 
    else
      'address or address range' 
    end
  end

  def add_error(record, attribute, value)
    record.errors[attribute] << (options[:message] || error_message)
  end
end

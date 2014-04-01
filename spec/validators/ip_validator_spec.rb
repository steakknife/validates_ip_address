require 'active_model'

def new_model(options)
  Class.new do # tableless model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :myfield
    validates :myfield, ip: (options.empty? ? true : options)

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end
  end
end

describe IpValidator do
  before(:each) do
    @validator_options = {}
  end

  context 'IP4 and IP6' do
    context 'Ranges and ip addresses' do
      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'validates an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(true)
          end

          it 'validates an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(true)
          end
        end

        context 'IPv6' do
          it 'validates an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(true)
          end

          it 'validates an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(true)
          end
        end

        it 'rejects nil' do
          expect(@model.new.valid?).to be(false)
        end

        it 'rejects empty' do
          expect(@model.new(myfield: '').valid?).to be(false)
        end

        it 'rejects garbage' do
          expect(@model.new(myfield: 'asdfasdfasdf').valid?).to be(false)
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'validates an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(true)
          end

          it 'validates an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(true)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'validates an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(true)
          end

          it 'validates an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(true)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Ranges only' do
      before(:each) do
        @validator_options[:ranges_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'does not validate an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(false)
          end

          it 'validates an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(true)
          end
        end

        context 'IPv6' do
          it 'does not validate an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'validates an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(true)
          end
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'does not validate an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(false)
          end

          it 'validates an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(true)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'does not validate an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(false)
          end

          it 'validates an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(true)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Addresses only' do
      before(:each) do
        @validator_options[:addresses_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'validates an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(true)
          end

          it 'does not validate an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(false)
          end
        end

        context 'IPv6' do
          it 'validates an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(true)
          end

          it 'does not validate an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(false)
          end
        end
      end

      context ' within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'validates an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(true)
          end

          it 'does not validate an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(false)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'validates an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(true)
          end

          it 'does not validate an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(false)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end
  end

  context 'IP4 only' do
    before(:each) do
      @validator_options[:ip4_only] = true
    end

    context 'Ranges and ip addresses' do
      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'validates an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(true)
          end

          it 'validates an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(true)
          end
        end

        context 'IPv6' do
          it 'does not validate an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(false)
          end
        end

        it 'rejects nil' do
          expect(@model.new.valid?).to be(false)
        end

        it 'rejects empty' do
          expect(@model.new(myfield: '').valid?).to be(false)
        end

        it 'rejects garbage' do
          expect(@model.new(myfield: 'asdfasdfasdf').valid?).to be(false)
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'validates an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(true)
          end

          it 'validates an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(true)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'does not validate an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(false)
          end

          it 'does not validate an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(false)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Ranges only' do
      before(:each) do
        @validator_options[:ranges_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'does not validate an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(false)
          end

          it 'validates an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(true)
          end
        end

        context 'IPv6' do
          it 'does not validate an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(false)
          end
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'does not validate an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(false)
          end

          it 'validates an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(true)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'does not validate an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(false)
          end

          it 'does not validate an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(false)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Addresses only' do
      before(:each) do
        @validator_options[:addresses_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'validates an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(true)
          end

          it 'does not validate an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(false)
          end
        end

        context 'IPv6' do
          it 'does not validate an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(false)
          end
        end
      end

      context ' within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'validates an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(true)
          end

          it 'does not validate an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(false)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'does not validate an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(false)
          end

          it 'does not validate an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(false)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end
  end

  context 'IP6 only' do
    before(:each) do
      @validator_options[:ip6_only] = true 
    end

    context 'Ranges and ip addresses' do
      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'does not validate an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(false)
          end

          it 'does not validate an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(false)
          end
        end

        context 'IPv6' do
          it 'validates an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(true)
          end

          it 'validates an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(true)
          end
        end

        it 'rejects nil' do
          expect(@model.new.valid?).to be(false)
        end

        it 'rejects empty' do
          expect(@model.new(myfield: '').valid?).to be(false)
        end

        it 'rejects garbage' do
          expect(@model.new(myfield: 'asdfasdfasdf').valid?).to be(false)
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'does not validate an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(false)
          end

          it 'does not validate an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(false)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'validates an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(true)
          end

          it 'validates an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(true)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Ranges only' do
      before(:each) do
        @validator_options[:ranges_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'does not validate an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(false)
          end

          it 'does not validate an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(false)
          end
        end

        context 'IPv6' do
          it 'does not validate an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'validates an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(true)
          end
        end
      end

      context ' within' do
        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'does not validate an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(false)
          end

          it 'does not validate an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(false)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'does not validate an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(false)
          end

          it 'validates an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(true)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end

    context 'Addresses only' do
      before(:each) do
        @validator_options[:addresses_only] = true
      end

      context 'Not within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          it 'does not validate an ipv4 address' do
            expect(@model.new(myfield: '1.2.3.4').valid?).to be(false)
          end

          it 'does not validate an ip4 range' do
            expect(@model.new(myfield: '1.2.3.4/16').valid?).to be(false)
          end
        end

        context 'IPv6' do
          it 'validates an ip6 address' do
            expect(@model.new(myfield: '::').valid?).to be(true)
          end

          it 'does not validate an ip6 range' do
            expect(@model.new(myfield: '::/48').valid?).to be(false)
          end
        end
      end

      context ' within' do
        before { @model = new_model(@validator_options) }

        context 'IPv4' do
          before { @model = new_model(@validator_options.merge(within: '10.0.0.0/8')) }
          
          it 'does not validate an ipv4 address within range' do
            expect(@model.new(myfield: '10.3.4.5').valid?).to be(false)
          end

          it 'does not validate an ipv4 range within range' do
            expect(@model.new(myfield: '10.3.4.0/24').valid?).to be(false)
          end

          it 'does not validate an ipv4 address outside range' do
            expect(@model.new(myfield: '172.1.1.1').valid?).to be(false)
          end

          it 'does not validate an ipv4 range outside range' do
            expect(@model.new(myfield: '172.0.0.0/8').valid?).to be(false)
          end
        end

        context 'IPv6' do
          before { @model = new_model(@validator_options.merge(within: 'abcd::/16')) }

          it 'validates an ipv6 address within range' do
            expect(@model.new(myfield: 'abcd::3:4').valid?).to be(true)
          end

          it 'does not validate an ipv6 range within range' do
            expect(@model.new(myfield: 'abcd::3:0/32').valid?).to be(false)
          end

          it 'does not validate an ipv6 address outside range' do
            expect(@model.new(myfield: '::').valid?).to be(false)
          end

          it 'does not validate an ipv6 range outside range' do
            expect(@model.new(myfield: '::/32').valid?).to be(false)
          end
        end
      end
    end
  end
end

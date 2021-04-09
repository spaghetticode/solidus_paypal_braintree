# frozen_string_literal: true

module SolidusPaypalBraintree
  class Address
    class Name
      attr_reader :first_name, :last_name, :value

      def initialize(*components)
        @value = components.join(' ').strip
        initialize_name_components(components)
      end

      def to_s
        @value
      end

      private

      def initialize_name_components(components)
        if components.size == 2
          @first_name = components[0].to_s
          @last_name = components[1].to_s
        else
          @first_name, @last_name = @value.split(/[[:space:]]/, 2)
        end
      end
    end

    delegate :address1,
      :address2,
      :city,
      :country,
      :phone,
      :state,
      :zipcode,
      to: :spree_address

    def initialize(spree_address)
      @spree_address = spree_address
    end

    def to_json(*_args)
      address_hash = {
        line1: spree_address.address1,
        line2: spree_address.address2,
        city: spree_address.city,
        postalCode: spree_address.zipcode,
        countryCode: spree_address.country.iso,
        phone: spree_address.phone,
        recipientName: name
      }

      if ::Spree::Config.address_requires_state && spree_address.country.states_required
        address_hash[:state] = spree_address.state.name
      end
      address_hash.to_json
    end

    def name
      @name ||= name_evaluator.to_s
    end
    alias_method :full_name, :name

    def firstname
      name_evaluator.first_name
    end
    alias_method :first_name, :firstname

    def lastname
      name_evaluator.last_name
    end
    alias_method :last_name, :lastname

    private

    def name_evaluator
      if SolidusSupport.combined_first_and_last_name_in_address?
        Name.new(spree_address.name)
      else
        Name.new(spree_address.firstname, spree_address.last_name)
      end
    end

    attr_reader :spree_address
  end
end

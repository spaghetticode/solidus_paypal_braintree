# frozen_string_literal: true

module SolidusPaypalBraintree
  class Address
    delegate :address1,
      :address2,
      :city,
      :country,
      :phone,
      :state,
      :zipcode,
      to: :spree_address

    def self.split(name)
      first, last = name.split(/[[:space:]]/, 2)
      { first: first, last: last }
    end

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
      if SolidusSupport.combined_first_and_last_name_in_address?
        spree_address.name
      else
        "#{firstname} #{lastname}"
      end
    end

    def firstname
      if SolidusSupport.combined_first_and_last_name_in_address?
        self.class.split(spree_address.name)[:first]
      else
        spree_address.firstname
      end
    end

    def lastname
      if SolidusSupport.combined_first_and_last_name_in_address?
        self.class.split(spree_address.name)[:last]
      else
        spree_address.lastname
      end
    end

    private

    attr_reader :spree_address
  end
end

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

    def initialize(spree_address)
      @spree_address = spree_address
    end

    def to_json(*_args)
      address_hash = {
        line1: address1,
        line2: address2,
        city: city,
        postalCode: zipcode,
        countryCode: country.iso,
        phone: phone,
        recipientName: "#{firstname} #{lastname}"
      }

      if ::Spree::Config.address_requires_state && country.states_required
        address_hash[:state] = state.name
      end
      address_hash.to_json
    end

    def firstname
      if spree_address.respond_to?(:name)
        TransactionAddress.split_name(spree_address.name).first
      else
        spree_address.firstname
      end
    end

    def lastname
      if spree_address.respond_to?(:name)
        TransactionAddress.split_name(spree_address.name).last
      else
        spree_address.lastname
      end
    end

    private

    attr_reader :spree_address
  end
end

# frozen_string_literal: true

module SolidusPaypalBraintree
  module Spree
    module AddressDecorator
      def firstname
        name.split(/[[:space:]]/, 2).first
      end

      def lastname
        name.split(/[[:space:]]/, 2)[1..-1].join(' ')
      end

      def full_name
        name
      end
        
      unless ::Spree::Address.methods.include?(:firstname)
        ::Spree::Address.prepend self
      end
    end
  end
end

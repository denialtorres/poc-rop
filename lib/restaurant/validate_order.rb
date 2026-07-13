# frozen_string_literal: true

require "dry/monads"

module Restaurant
  # first gate. checks the order is well-formated BEFORE touching menu/stock
  class ValidateOrder
    include Dry::Monads[:result]

    # bind step: value -> Result. Success(Order) stays on rail, Failure derails.
    def self.call(order)
      new.call(order)
    end

    def call(order)
      return Failure(InvalidOrderError.new("customer name required")) if blank?(order.customer_name)
      return Failure(InvalidOrderError.new("customer has no items")) if order.items.nil? || order.items.empty?

      order.items.each do |item|
        return Failure(InvalidOrderError.new("item missin name")) if blank?(item[:name])

        quantity = item[:qty]

        unless quantity.is_a?(Integer) && quantity.positive?
          return Failure(InvalidOrderError.new("item #{item[:name.inspect]} has invalid quantity"))
        end
      end

      Success(order) # all good, pass cargo down the rails
    end

    private

    def blank?(value)
      value.nil? || value&.to_s&.strip&.empty?
    end
  end
end

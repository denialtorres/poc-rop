# frozen_string_literal: true

require "dry/monads"

module Restaurant
  # total = subtotal - discount. derails if it goes negative.
  class CalcTotal
    include Dry::Monads[:result]

    def self.call(order)
      new.call(order)
    end

    def call(order)
      order.total = order.subtotal - order.discount

      if order.total.negative?
        return Failure(NegativeTotalError.new("total negative: #{order.total}"))
      end

      Success(order)
    end
  end
end

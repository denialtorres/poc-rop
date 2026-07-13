# frozen_string_literal: true

require "dry/monads"

module Restaurant
  # transform: sum line prices into order.subtotal
  class CalcSubtotal
    include Dry::Monads[:result]


    def self.call(order)
      new.call(order)
    end

    def call(order)
      order.subtotal = order.line_items.sum do |line|
        line[:menu_item].price * line[:qty]
      end

      if order.subtotal.negative?
        return Failure(NegativeSubtotalError.new("subtotal negative: #{order.subtotal}"))
      end

      Success(order)
    end
  end
end

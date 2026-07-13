# frozen_string_literal: true

require 'dry/monads'

module Restaurant
  # verifies enough stock for each line. derails on first shortfall
  class CheckStock
    include Dry::Monads[:result]

    def self.call(order)
      new.call(order)
    end

    def call(order)
      order.line_items.each do |line|
        item = line[:menu_item]
        qty = line[:qty]

        if qty > item.stock
          return Failure(OutOfStockError.new("#{item.name} - wanted #{qty}, only #{item.stock} left"))
        end
      end

      Success(order)
    end
  end
end

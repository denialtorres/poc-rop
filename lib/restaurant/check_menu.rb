# frozen_string_literal: true

require 'dry/monads'

module Restaurant
  # resolve raw item hashes -> MenuItem structs, derails if any not on menu
  class CheckMenu
    include Dry::Monads[:result]

    def self.call(order)
      new.call(order)
    end

    def call(order)
      order.line_items = order.items.map do |item|
                           menu_item = Menu.find(item[:name])
                           return Failure(ItemNotOnMenuError.new("#{item[:name]} not on menu")) if menu_item.nil?

                           { menu_item:, qty: item[:qty] }
                         end
      Success(order)
    end
  end
end

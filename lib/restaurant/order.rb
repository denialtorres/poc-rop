# frozen_string_literal: true

module Restaurant
  # Main object representing an order, rides the rails
  # each step reads/writes fields on it
  class Order
    attr_accessor :customer_name, :items, :coupon_code,
                  :line_items,
                  :subtotal, :total, :discount, :ticket_id

    def initialize(customer_name:, items:, coupon_code: nil)
      @customer_name = customer_name
      @items = items # Array of raw items hashes from request
      @coupon_code = coupon_code
      @line_items = [] # filtered by CheckMenu [{ menu_item:, qty: }]
      @subtotal = 0
      @total = 0
      @discount = 0
      @ticket_id = nil
    end
  end
end

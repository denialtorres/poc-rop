# frozen_string_literal: true

module Restaurant
  # Main object representing an order, rides the rails
  # each step reads/writes fields on it
  class Order
    attr_accessor :customer_name, :items, :coupon_code,
                  :special_requests, :parsed_requests,
                  :line_items,
                  :subtotal, :total, :discount, :ticket_id

    def initialize(customer_name:, items:, coupon_code: nil, special_requests: nil)
      @customer_name = customer_name
      @items = items # Array of raw items hashes from request
      @coupon_code = coupon_code
      @special_requests = special_requests   # raw text: "no onions, allergic to peanuts"
      @parsed_requests  = nil                # filled by AnalyzeSpecialRequests
      @line_items = [] # filtered by CheckMenu [{ menu_item:, qty: }]
      @subtotal = 0
      @total = 0
      @discount = 0
      @ticket_id = nil
    end
  end
end

# frozen_string_literal: true

require "dry/monads"
require 'pry'

module Restaurant
  # the rail. owns step order + runs the train (order)
  class PlaceOrder
    include Dry::Monads[:result] # gives Success, Failure objects

    def call(customer_name:, items:, coupon_code: nil)
      order = Order.new(customer_name:, items:, coupon_code:)

      Success(order)
        .bind(&ValidateOrder.method(:call)) # call the ValidateOrder#call method, can fail
        .bind(&CheckMenu.method(:call)) # call the CheckMenu#call method, can fail
        .bind(&CheckStock.method(:call)) # call the CheckStock#call method, can fail
        .bind(&CalcSubtotal.method(:call)) # call the CalcSubtotal#call method, can fail
        .bind(&ApplyCoupon.method(:call)) # call the ApplyCoupon#call method, can fail
        .bind(&CalcTotal.method(:call)) # call the CalcTotal#call method, can fail
        .bind(&CreateTicket.method(:call)) # call the CreateTicket#call method
    end
  end
end

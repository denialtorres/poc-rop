# frozen_string_literal: true

require "dry/monads"

module Restaurant
  # applies coupon discount to order.discount. derails on unknown code.
  class ApplyCoupon
    include Dry::Monads[:result]

    def self.call(order)
      new.call(order)
    end

    def call(order)
      return Success(order) if order.coupon_code.nil?

      coupon = Coupons.find(order.coupon_code)
      if coupon.nil?
        return Failure(InvalidCouponError.new("unknown coupon: #{order.coupon_code}"))
      end

      order.discount = order.subtotal * coupon.percent
      Success(order)
    end
  end
end

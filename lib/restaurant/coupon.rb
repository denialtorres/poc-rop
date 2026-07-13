# frozen_string_literal: true

module Restaurant
  # percent = fraction off subtotal (0.10 = 10% off)
  Coupon = Struct.new(:code, :percent, keyword_init: true)

  module Coupons
    CODES = {
      "WELCOME10" => Coupon.new(code: "WELCOME10", percent: 0.10),
      "HALFOFF"   => Coupon.new(code: "HALFOFF",   percent: 0.50),
      "SAVE5"     => Coupon.new(code: "SAVE5",     percent: 0.05)
    }.freeze

    def self.find(code)
      CODES[code]
    end
  end
end

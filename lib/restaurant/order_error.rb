# frozen_string_literal: true

module Restaurant
  class OrderError < StandardError; end

  # subtypes = one per fail reason, easy to pattern match later
  class InvalidOrderError < OrderError; end
  class ItemNotOnMenuError < OrderError; end
  class OutOfStockError < OrderError; end
  class InvalidCouponError < OrderError; end
  class PaymentDeclinedError < OrderError; end
  class NegativeTotalError < OrderError; end
  class SpecialRequestError < OrderError; end
end

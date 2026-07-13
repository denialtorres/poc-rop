# frozen_string_literal: true

require "dry/monads"
require "securerandom"

module Restaurant
  # final station: stamps a ticket id. order now "placed".
  class CreateTicket
    include Dry::Monads[:result]

    def self.call(order)
      new.call(order)
    end

    def call(order)
      order.ticket_id = "TICKET-#{SecureRandom.hex(4).upcase}"
      Success(order)
    end
  end
end

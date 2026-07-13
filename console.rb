# frozen_string_literal: true

# Load console: `ruby console.rb`
# Loads gems + every .rb under lib/, then drops into IRB.

require "bundler/setup"
require "dry/monads"
require "dotenv/load"
require "irb"

# require all lib files. order_error/order/menu first (deps), then rest.
Dir[File.join(__dir__, "lib", "restaurant", "*.rb")].sort.each { |f| require f }

puts "Restaurant console. Loaded:"
puts Restaurant.constants.sort.map { |c| "  Restaurant::#{c}" }

IRB.start

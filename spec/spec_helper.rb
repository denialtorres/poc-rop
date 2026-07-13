# frozen_string_literal: true

require "bundler/setup"
require "dry/monads"

# dummy key so llm_config's ENV.fetch doesn't blow up on load.
# RubyLLM is always mocked in specs — no real Gemini call happens.
ENV["GEMINI_API_KEY"] ||= "test-key"

# load every lib file (constants resolve at call time, so glob order is fine)
Dir[File.join(__dir__, "..", "lib", "restaurant", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.order = :random
end

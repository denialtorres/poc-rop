# frozen_string_literal: true
require "ruby_llm"
require "dry/monads"
require "json"


module Restaurant
  # AI station. Parses free-text customer notes into structure data.
  class AnalyzeSpecialRequests
    include Dry::Monads[:result]

    MODEL = "gemini-3.5-flash"

    INSTRUCTION = <<~PROMPT
      You parse a restaurant customer's free-text special requests into structured data.
      Given the raw note, extract:
        - modifications: array of concrete item changes (e.g. "no onions", "extra spicy")
        - allergens: array of allergens the customer mentions (e.g. "peanuts", "gluten")
      Respond with ONLY valid JSON, no markdown, in this exact shape:
      { "modifications": [<string>], "allergens": [<string>] }
      If the note is empty or has no actionable content, return empty arrays.
    PROMPT

    def self.call(order)
      new.call(order)
    end

    def call(order)
      # no note = nothing to parse, stay on the happy track
      return Success(order) if blank?(order.special_requests)

      chat = RubyLLM.chat(model: MODEL)
      chat.with_instructions(INSTRUCTION)
      response = chat.ask("Customer note: #{order.special_requests}")

      order.parsed_requests = parse(response.content)
      Success(order)
    rescue StandardError => e
      Failure(SpecialRequestError.new("special request parse failed: #{e.message}"))
    end

    private

    def parse(raw)
      # strip markdown fences if the model wraps output
      cleaned = raw.strip.gsub(/\A```(?:json)?/, "").gsub(/```\z/, "").strip
      JSON.parse(cleaned, symbolize_names: true)
    end

    def blank?(str)
      str.nil? || str.to_s.strip.empty?
    end
  end
end

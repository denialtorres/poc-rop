# poc-rop — Railway Oriented Programming in Ruby

A proof of concept exploring **Railway Oriented Programming (ROP)** in Ruby, using a restaurant order flow as the example domain.

## The idea

ROP models a pipeline as a train on two tracks: a **success track** and a **failure track**. Each step (a "station") receives the order, does one thing, and returns either `Success(order)` or `Failure(error)`. The moment any station fails, the train switches to the failure track and every remaining station is skipped — no nested `if`/`rescue`, errors handled once at the end.

Built with [`dry-monads`](https://dry-rb.org/gems/dry-monads/) (`Success` / `Failure` + `bind`).

## The rail

`PlaceOrder` chains the stations. Every station uses `.bind` and returns a `Result`:

```
ValidateOrder → CheckMenu → CheckStock → AnalyzeSpecialRequests
  → CalcSubtotal → ApplyCoupon → CalcTotal → CreateTicket
```

```ruby
# frozen_string_literal: true

require "dry/monads"
require 'pry'

module Restaurant
  # the rail. owns step order + runs the train (order)
  class PlaceOrder
    include Dry::Monads[:result] # gives Success, Failure objects

    def call(customer_name:, items:, coupon_code: nil, special_requests: nil)
      order = Order.new(customer_name:, items:, coupon_code:, special_requests:)

      Success(order)
        .bind(&ValidateOrder.method(:call)) # call the ValidateOrder#call method, can fail
        .bind(&CheckMenu.method(:call)) # call the CheckMenu#call method, can fail
        .bind(&CheckStock.method(:call)) # call the CheckStock#call method, can fail
        .bind(&AnalyzeSpecialRequests.method(:call))   # AI station
        .bind(&CalcSubtotal.method(:call)) # call the CalcSubtotal#call method, can fail
        .bind(&ApplyCoupon.method(:call)) # call the ApplyCoupon#call method, can fail
        .bind(&CalcTotal.method(:call)) # call the CalcTotal#call method, can fail
        .bind(&CreateTicket.method(:call)) # call the CreateTicket#call method
    end
  end
end

```

Any failure (bad input, item not on menu, out of stock, unknown coupon, …) short-circuits the rest and surfaces as a typed error (`OutOfStockError`, `InvalidCouponError`, …).

## Highlight: the AI station

```ruby
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

```

`AnalyzeSpecialRequests` is an **LLM-powered station**. It takes a customer's free-text note ("no onions, allergic to peanuts, extra spicy") and asks **Gemini** (via the [`ruby_llm`](https://github.com/crmne/ruby_llm) gem) to parse it into structured data:

```ruby
{ modifications: ["no onions", "extra spicy"], allergens: ["peanuts"] }
```


<img width="808" height="612" alt="Screenshot 2026-07-12 at 9 21 58 p m" src="https://github.com/user-attachments/assets/a3612cf0-9e3e-4608-b64a-74550e49aeb9" />


It fits the railway like any other station: enriches the order on success, returns `Failure(SpecialRequestError)` if the call or the JSON parse fails. If there's no note, it skips the LLM entirely and stays on the happy track.

## Setup

```bash
bundle install
cp .env.example .env   # then add your GEMINI_API_KEY
```

## Run it

Interactive console (loads all classes):

```bash
ruby console.rb
```

```ruby
Restaurant::PlaceOrder.new.call(
  customer_name: "Dani",
  items: [{ name: "Margherita Pizza", qty: 1 }],
  special_requests: "no basil, allergic to peanuts"
)
```

Tests (Gemini is fully mocked — no real API calls):

```bash
bundle exec rspec
```

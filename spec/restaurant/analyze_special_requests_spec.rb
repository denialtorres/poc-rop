# frozen_string_literal: true

module Restaurant
  RSpec.describe AnalyzeSpecialRequests do
    subject(:result) { described_class.call(order) }

    let(:order) do
      Order.new(
        customer_name: "Dani",
        items: [{ name: "Coke", qty: 1 }],
        special_requests: note
      )
    end

    # fake Gemini boundary — no real calls in specs
    let(:chat)         { double("RubyLLM::Chat", with_instructions: nil, ask: llm_response) }
    let(:llm_response) { double("response", content: raw_content) }
    let(:raw_content)  { '{"modifications":["no onions"],"allergens":["peanuts"]}' }

    context "when the note is blank" do
      let(:note) { nil }

      it "skips the LLM entirely and succeeds" do
        expect(RubyLLM).not_to receive(:chat)
        expect(result).to be_success
      end

      it "leaves parsed_requests nil" do
        expect(result.value!.parsed_requests).to be_nil
      end
    end

    context "when the LLM returns clean JSON" do
      let(:note) { "no onions, allergic to peanuts" }

      before { allow(RubyLLM).to receive(:chat).and_return(chat) }

      it "parses and stores the structured result" do
        expect(result.value!.parsed_requests).to eq(
          modifications: ["no onions"],
          allergens: ["peanuts"]
        )
      end
    end

    context "when the LLM wraps JSON in markdown fences" do
      let(:note)        { "extra spicy" }
      let(:raw_content) { "```json\n{\"modifications\":[\"extra spicy\"],\"allergens\":[]}\n```" }

      before { allow(RubyLLM).to receive(:chat).and_return(chat) }

      it "strips the fences and parses" do
        expect(result.value!.parsed_requests).to eq(
          modifications: ["extra spicy"],
          allergens: []
        )
      end
    end

    context "when the LLM call raises" do
      let(:note) { "no onions" }

      before { allow(RubyLLM).to receive(:chat).and_raise(StandardError.new("network down")) }

      it "derails with SpecialRequestError" do
        expect(result).to be_failure
        expect(result.failure).to be_a(SpecialRequestError)
      end
    end

    context "when the LLM returns non-JSON" do
      let(:note)        { "no onions" }
      let(:raw_content) { "sorry, I could not parse that" }

      before { allow(RubyLLM).to receive(:chat).and_return(chat) }

      it "derails with SpecialRequestError" do
        expect(result).to be_failure
        expect(result.failure).to be_a(SpecialRequestError)
      end
    end
  end
end

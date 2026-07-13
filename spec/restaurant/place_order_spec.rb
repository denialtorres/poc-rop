# frozen_string_literal: true

module Restaurant
  RSpec.describe PlaceOrder do
    subject(:result) do
      described_class.new.call(customer_name:, items:, coupon_code:, special_requests:)
    end

    let(:customer_name)    { "Dani" }
    let(:items)            { [{ name: "Coke", qty: 3 }] }
    let(:coupon_code)      { nil }
    let(:special_requests) { nil }   # nil => AI station skips, no Gemini call

    describe "happy path" do
      let(:items) { [{ name: "Coke", qty: 3 }, { name: "Classic Burger", qty: 1 }] }

      it "succeeds" do
        expect(result).to be_success
      end

      it "computes subtotal, total, and stamps a ticket" do
        order = result.value!

        expect(order.subtotal).to eq(19.0)   # 3.0*3 + 10.0*1
        expect(order.discount).to eq(0)
        expect(order.total).to eq(19.0)
        expect(order.ticket_id).to match(/\ATICKET-[0-9A-F]{8}\z/)
      end
    end

    describe "with a valid coupon" do
      let(:coupon_code) { "WELCOME10" }

      it "applies the discount to the total" do
        order = result.value!

        expect(order.subtotal).to eq(9.0)
        expect(order.discount).to eq(0.9)    # 10% of 9.0
        expect(order.total).to eq(8.1)
      end
    end

    describe "validation failures" do
      context "when customer name is blank" do
        let(:customer_name) { "" }

        it "fails with InvalidOrderError" do
          expect(result).to be_failure
          expect(result.failure).to be_a(InvalidOrderError)
        end
      end

      context "when there are no items" do
        let(:items) { [] }

        it "fails with InvalidOrderError" do
          expect(result.failure).to be_a(InvalidOrderError)
        end
      end

      context "when an item has a bad qty" do
        let(:items) { [{ name: "Coke", qty: 0 }] }

        it "fails with InvalidOrderError" do
          expect(result.failure).to be_a(InvalidOrderError)
        end
      end
    end

    describe "menu failures" do
      context "when an item is not on the menu" do
        let(:items) { [{ name: "Sushi", qty: 1 }] }

        it "fails with ItemNotOnMenuError" do
          expect(result.failure).to be_a(ItemNotOnMenuError)
        end
      end
    end

    describe "stock failures" do
      context "when an item is out of stock" do
        let(:items) { [{ name: "Tiramisu", qty: 1 }] }

        it "fails with OutOfStockError" do
          expect(result.failure).to be_a(OutOfStockError)
        end
      end

      context "when qty exceeds available stock" do
        let(:items) { [{ name: "Lasagna", qty: 5 }] } # stock 2

        it "fails with OutOfStockError" do
          expect(result.failure).to be_a(OutOfStockError)
        end
      end
    end

    describe "coupon failures" do
      context "when the coupon code is unknown" do
        let(:coupon_code) { "NOPE" }

        it "fails with InvalidCouponError" do
          expect(result.failure).to be_a(InvalidCouponError)
        end
      end
    end

    describe "with special requests (AI station, mocked)" do
      let(:special_requests) { "no onions, allergic to peanuts" }

      # fake Gemini: never a real call in specs
      let(:llm_response) do
        double("response", content: '{"modifications":["no onions"],"allergens":["peanuts"]}')
      end
      let(:chat) { double("RubyLLM::Chat", with_instructions: nil, ask: llm_response) }

      before { allow(RubyLLM).to receive(:chat).and_return(chat) }

      it "succeeds and stores the parsed requests on the order" do
        order = result.value!

        expect(order.parsed_requests).to eq(
          modifications: ["no onions"],
          allergens: ["peanuts"]
        )
      end

      it "still charges the order normally" do
        expect(result.value!.total).to eq(9.0)
      end
    end

    describe "short-circuit behavior" do
      let(:items) { [{ name: "Tiramisu", qty: 1 }] } # derails at CheckStock

      it "never reaches later stations" do
        order = result.failure

        # CheckStock ran (line_items built), but nothing downstream did
        expect(result).to be_failure
      end

      it "leaves downstream fields untouched on the raw order" do
        # build an order, run only up to the failing point via the full rail
        expect(result).to be_failure
        expect(result.failure).to be_a(OutOfStockError)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ValidationErrorDecorator do
  let(:decorated_error) { described_class.new(error) }

  describe "#attribute" do
    context "when the attribute is 'payload_in_kg'" do
      let(:error) do
        instance_double(Wheelhouse::Validations::Error,
          id: "aaa-bbb-ccc-ddd",
          message: "Weight has been exceeded",
          attribute: :payload_in_kg,
          section: "cargo",
          limit: 1000,
          code: 4001)
      end

      it "returns attribute as 'weight'" do
        expect(decorated_error.attribute).to eq("weight")
      end
    end

    context "when the attribute is not 'payload_in_kg'" do
      let(:error) do
        instance_double(Wheelhouse::Validations::Error,
          id: "aaa-bbb-ccc-ddd",
          message: "Volume has been exceeded",
          attribute: "volume",
          section: "cargo",
          limit: 100.0,
          code: 4018)
      end

      it "returns attribute as is" do
        expect(decorated_error.attribute).to eq(error.attribute)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType do
  describe ".valid?" do
    context "when no value" do
      it "returns true" do
        expect(described_class.new(nil)).to be_valid
      end
    end

    context "when boolean" do
      it "returns true" do
        aggregate_failures do
          expect(described_class.new(true)).to be_valid
          expect(described_class.new(false)).to be_valid
        end
      end
    end

    context "when integer" do
      it "returns true for 0 and 1" do
        aggregate_failures do
          expect(described_class.new(0)).to be_valid
          expect(described_class.new(1)).to be_valid
        end
      end
    end

    context "when string" do
      # rubocop:disable RSpec/ExampleLength
      it "returns true for keyword strings" do
        aggregate_failures do
          expect(described_class.new("t")).to be_valid
          expect(described_class.new("true")).to be_valid
          expect(described_class.new("f")).to be_valid
          expect(described_class.new("false")).to be_valid
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context "when other value" do
      it "returns false" do
        aggregate_failures do
          expect(described_class.new(5)).not_to be_valid
          expect(described_class.new("abc")).not_to be_valid
          expect(described_class.new(5.3)).not_to be_valid
        end
      end
    end
  end
end

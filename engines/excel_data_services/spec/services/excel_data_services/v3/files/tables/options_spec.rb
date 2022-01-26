# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Tables::Options do
  let(:service) { described_class.new(options: options.merge(test_options)) }

  let(:options) do
    {
      sanitizer: "text",
      validator: "string",
      required: true,
      type: :object,
      fallback: "standard",
      unique: false,
      dynamic: false,
      alternative_keys: ["service_level"]
    }
  end
  let(:test_options) { {} }

  describe "#errors" do
    context "when the options are valid" do
      it "returns an empty array" do
        expect(service.errors).to be_empty
      end
    end

    context "when 'required' argument is invalid" do
      let(:test_options) { { required: "blue" } }
      let(:required_data_missing_error) { "Option ['required'] must be a boolean value or left blank" }

      it "returns an error message" do
        expect(service.errors.map(&:reason)).to include(required_data_missing_error)
      end
    end
  end

  describe "#sanitizer" do
    it "returns the value from the provided options under the key `sanitizer`" do
      expect(service.sanitizer).to eq(options[:sanitizer])
    end

    context "when sanitizer is omitted" do
      let(:test_options) { { sanitizer: nil } }

      it "returns the fallback value for the key `sanitizer`" do
        expect(service.sanitizer).to eq("text")
      end
    end
  end

  describe "#validator" do
    it "returns the value from the provided options under the key `validator`" do
      expect(service.validator).to eq(options[:validator])
    end

    context "when validator is omitted" do
      let(:test_options) { { validator: nil } }

      it "returns the fallback value for the key `validator`" do
        expect(service.validator).to eq("string")
      end
    end
  end

  describe "#required" do
    it "returns the value from the provided options under the key `required`" do
      expect(service.required).to eq(options[:required])
    end
  end

  describe "#unique" do
    it "returns the value from the provided options under the key `unique`" do
      expect(service.unique).to eq(false)
    end

    context "when unique is omitted" do
      let(:test_options) { { unique: nil } }

      it "returns the fallback value for the key `validator`" do
        expect(service.unique).to eq(false)
      end
    end
  end

  describe "#alternative_keys" do
    it "returns the value from the provided options under the key `alternative_keys`" do
      expect(service.alternative_keys).to eq(options[:alternative_keys])
    end

    context "when alternative_keys is omitted" do
      let(:test_options) { { alternative_keys: nil } }

      it "returns the fallback value for the key `validator`" do
        expect(service.alternative_keys).to eq([])
      end
    end
  end

  describe "#fallback" do
    it "returns the value from the provided options under the key `fallback`" do
      expect(service.fallback).to eq(options[:fallback])
    end

    context "when fallback is omitted" do
      let(:test_options) { { fallback: nil } }

      it "returns the fallback value for the key `validator`" do
        expect(service.fallback).to eq(nil)
      end
    end
  end

  describe "#type" do
    it "returns the value from the provided options under the key `type`" do
      expect(service.type).to eq(options[:type])
    end

    context "when type is omitted" do
      let(:test_options) { { type: nil } }

      it "returns the fallback value for the key `validator`" do
        expect(service.type).to eq(:object)
      end
    end
  end

  describe "#dynamic" do
    it "returns the value from the provided options under the key `dynamic`" do
      expect(service.dynamic).to eq(options[:dynamic])
    end
  end

  describe "#header_row" do
    it "returns the value from the provided options under the key `header_row`" do
      expect(service.header_row).to eq(options[:header_row])
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ProfileUpdateContract do
  describe "#call" do
    let(:email) { "test@itsmycargo.test" }
    let(:first_name) { "Bob" }
    let(:last_name) { "Smith" }
    let(:phone) { "0123456789" }
    let(:language) { "en-US" }
    let(:locale) { "en-US" }
    let(:currency) { "EUR" }
    let(:password) { nil }
    let(:params) do
      {
        email: email,
        password: password,
        firstName: first_name,
        lastName: last_name,
        phone: phone,
        language: language,
        locale: locale,
        currency: currency
      }
    end
    let(:result) { described_class.new.call(params) }

    before do
      FactoryBot.create(:treasury_exchange_rate, from: "EUR")
    end

    context "when all params are present and valid" do
      it "returns no errors" do
        expect(result.errors.to_h).to be_empty
      end
    end

    context "when currency is invalid" do
      let(:currency) { "123" }

      it "returns errors indicating currency is incorrect" do
        expect(result.errors.to_h).to eq({ currency: ["Invalid currency. Refer to ISO 4217 for list of valid codes"] })
      end
    end

    context "when language is invalid" do
      let(:language) { "po-OP" }

      it "returns errors indicating language is incorrect" do
        expect(result.errors.to_h).to eq({ language: ["Invalid language option. Must be one of: en-GB|en-US|de-DE|es-ES"] })
      end
    end

    context "when locale is invalid" do
      let(:locale) { "po-OP" }

      it "returns errors indicating locale is incorrect" do
        expect(result.errors.to_h).to eq({ locale: ["Invalid locale option. Must be one of: en-GB|en-US|de-DE|es-ES"] })
      end
    end

    context "when email is invalid" do
      let(:email) { "itsmycargo" }

      it "returns errors indicating email is incorrect" do
        expect(result.errors.to_h).to eq({ email: ["Invalid email"] })
      end
    end

    context "when the password is too weak" do
      let(:password) { "butter" }

      it "returns errors indicating password is too weak" do
        expect(result.errors.to_h).to eq({ password: ["Password is too weak"] })
      end
    end
  end
end

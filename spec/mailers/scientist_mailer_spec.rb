# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScientistMailer, type: :mailer do
  let(:experiment_name) { "my-experiment" }
  let(:app_name) { "imc-app" }

  before do
    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
  end

  describe "complete_mail" do
    let(:has_errors) { false }
    let(:query_input_params) { { foo: "bar" } }
    let(:control_value) { nil }
    let(:candidate_value) { nil }

    let(:mail) do
      described_class.with(
        experiment_name: experiment_name,
        app_name: app_name,
        has_errors: has_errors,
        query_input_params: query_input_params,
        control_value: control_value,
        candidate_value: candidate_value
      ).complete_email
    end

    it "renders", :aggregate_failures do
      expect(mail.subject).to eq("[ItsMyCargo] Experiment \"my-experiment\" completed successfully")
      expect(mail.from).to eq(["notifications@itsmycargo.shop"])
      expect(mail.to).to eq(["dev-services@itsmycargo.com"])
    end
  end
end

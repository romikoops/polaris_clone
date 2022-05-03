# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillDoorkeeperApplicationsOnDomainsWorker, type: :worker do
  let!(:dipper_domains) do
    [
      FactoryBot.create(:organizations_domain, domain: "demo.itsmycargo.com"),
      FactoryBot.create(:organizations_domain, domain: "demo.itsmycargo.shop")
    ]
  end
  let!(:bridge_domain) { FactoryBot.create(:organizations_domain, domain: "control.itsmycargo.com") }
  let!(:siren_domains) do
    described_class::SIREN_DOMAINS.map do |domain|
      FactoryBot.create(:organizations_domain, domain: domain)
    end
  end
  let!(:dipper_application) { FactoryBot.create(:application, name: "dipper") }
  let!(:bridge_application) { FactoryBot.create(:application, name: "bridge") }
  let!(:siren_application) { FactoryBot.create(:application, name: "siren") }

  before { described_class.new.perform }

  it "sets the correct application for the Dipper domains" do
    dipper_domains.each do |domain|
      expect(domain.reload.application_id).to eq(dipper_application.id)
    end
  end

  it "sets the correct application for the Siren domains" do
    siren_domains.each do |domain|
      expect(domain.reload.application_id).to eq(siren_application.id)
    end
  end

  it "sets the correct application for the Bridge domains" do
    expect(bridge_domain.reload.application_id).to eq(bridge_application.id)
  end
end

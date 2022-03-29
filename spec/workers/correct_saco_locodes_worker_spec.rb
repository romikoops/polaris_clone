# frozen_string_literal: true

require "rails_helper"

RSpec.describe CorrectSacoLocodesWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "saco") }

  before do
    described_class::VALID_TO_INVALID_MAP.values.map do |locode|
      FactoryBot.create(:legacy_hub,
        organization: organization,
        nexus: FactoryBot.build(:legacy_nexus, organization: organization, locode: locode),
        hub_code: locode)
    end
    described_class.new.perform
  end

  it "updates the invalid nexuses with the correct locode", :aggregate_failures do
    expect(Legacy::Nexus.where(organization: organization).pluck(:locode)).to match_array(described_class::VALID_TO_INVALID_MAP.keys)
    expect(Legacy::Hub.where(organization: organization).pluck(:hub_code)).to match_array(described_class::VALID_TO_INVALID_MAP.keys)
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Legacy::BackkfillDeletedAtForOutdatedNotesWorker, type: :worker do
  describe "#perform" do
    before { create_two_organizations_and_two_pricings_with_duplicated_notes }

    it "does not soft delete outdated notes for each organization, when they are the latest notes", :aggregate_failures do
      described_class.new.perform
      expect(Legacy::Note.first).to have_attributes(body: "Current remark body with Cargo for henningharders", deleted_at: nil)
      expect(Legacy::Note.second).to have_attributes(body: "Current Coc body with Cargo for henningharders", deleted_at: nil)
      expect(Legacy::Note.third).to have_attributes(body: "Current remark body with Cargo for saco", deleted_at: nil)
      expect(Legacy::Note.last).to have_attributes(body: "Current Coc body with Cargo for saco", deleted_at: nil)
    end

    it "soft deletes outdated notes for each organization, when they are not the latest notes", :aggregate_failures do
      described_class.new.perform
      expect(Legacy::Note.only_deleted.first).to have_attributes(body: "Old remark body with Cargo for henningharders", deleted_at: kind_of(ActiveSupport::TimeWithZone))
      expect(Legacy::Note.only_deleted.second).to have_attributes(body: "Old Coc body with Cargo for henningharders", deleted_at: kind_of(ActiveSupport::TimeWithZone))
      expect(Legacy::Note.only_deleted.third).to have_attributes(body: "Old remark body with Cargo for saco", deleted_at: kind_of(ActiveSupport::TimeWithZone))
      expect(Legacy::Note.only_deleted.last).to have_attributes(body: "Old Coc body with Cargo for saco", deleted_at: kind_of(ActiveSupport::TimeWithZone))
    end

    def create_two_organizations_and_two_pricings_with_duplicated_notes
      organization_one = FactoryBot.create(:organizations_organization, slug: "henningharders")
      organization_two = FactoryBot.create(:organizations_organization, slug: "saco")

      [organization_one, organization_two].each do |org|
        pricing = FactoryBot.create(:pricings_pricing, cargo_class: "Cargo for #{org.slug}", organization: org)
        FactoryBot.create(:legacy_note, organization: org, header: "Remarks", body: "Old remark body with #{pricing.cargo_class}", pricings_pricing_id: pricing.id, created_at: 2.hours.ago, updated_at: 1.hour.ago)
        FactoryBot.create(:legacy_note, organization: org, header: "Remarks", body: "Current remark body with #{pricing.cargo_class}", pricings_pricing_id: pricing.id, created_at: 2.hours.ago, updated_at: Time.now.utc)
        FactoryBot.create(:legacy_note, organization: org, header: "Coc Zertifikat Erforderlich", body: "Old Coc body with #{pricing.cargo_class}", pricings_pricing_id: pricing.id, created_at: 2.hours.ago, updated_at: 1.hour.ago)
        FactoryBot.create(:legacy_note, organization: org, header: "Coc Zertifikat Erforderlich", body: "Current Coc body with #{pricing.cargo_class}", pricings_pricing_id: pricing.id, created_at: 2.hours.ago, updated_at: Time.now.utc)
      end
    end
  end
end

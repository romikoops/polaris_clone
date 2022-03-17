# frozen_string_literal: true

require "rails_helper"
RSpec.describe PurgeTruckingTableWorker, type: :worker do
  before do
    trucking_location = FactoryBot.create(:trucking_location)
    PurgeTruckingTableWorker::SLUGS_TO_SAVE.each do |slug|
      organization = FactoryBot.create(:organizations_organization, slug: slug)
      FactoryBot.create(:trucking_trucking, organization: organization, location: trucking_location) # current_trucking
      FactoryBot.create(:trucking_trucking, organization: organization, location: trucking_location, validity: Range.new(2.years.ago, 1.year.ago)) # expired_trucking
      FactoryBot.create(:trucking_trucking, organization: organization, location: trucking_location, deleted_at: 1.year.ago) # deleted_trucking
    end
    FactoryBot.create(:trucking_trucking, location: trucking_location)
    FactoryBot.create(:trucking_trucking, location: trucking_location, validity: Range.new(2.years.ago, 1.year.ago))
    FactoryBot.create(:trucking_trucking, location: trucking_location, deleted_at: 1.year.ago)
  end

  let(:organizations_to_preserve) { Organizations::Organization.where(slug: PurgeTruckingTableWorker::SLUGS_TO_SAVE) }

  describe "#perform" do
    before { described_class.new.perform }

    it "permanently deletes all Trucking::Trucking not in the SLUGS_TO_SAVE organization list, currently valid or not, as well as soft deleted" do
      expect(Trucking::Trucking.with_deleted.where.not(organization: organizations_to_preserve)).to be_empty
    end

    it "permanently deletes all Trucking::Trucking in the SLUGS_TO_SAVE organization list, leaving the currently valid ones", :aggregate_failures do
      expect(Trucking::Trucking.with_deleted.current.pluck(:organization_id)).to match_array(organizations_to_preserve.pluck(:id))
      expect(Trucking::Trucking.only_deleted).to be_empty
      expect(Trucking::Trucking.with_deleted.where("UPPER(validity) < now()")).to be_empty
    end
  end
end

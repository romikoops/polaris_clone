# frozen_string_literal: true

require "rails_helper"

module Booking
  RSpec.describe Query, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:origin_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
    let(:destination_hub) { FactoryBot.create(:legacy_hub, organization: organization, name: "Test Hub") }

    it "builds a valid object" do
      expect(FactoryBot.build(:booking_query, organization: organization,
                                              origin: origin_hub, destination: destination_hub)).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: booking_queries
#
#  id                      :uuid             not null, primary key
#  category                :integer
#  desired_start_date      :datetime
#  destination_type        :string
#  legacy_destination_type :string
#  legacy_origin_type      :string
#  origin_type             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_id              :uuid
#  creator_id              :uuid
#  destination_id          :uuid
#  legacy_destination_id   :bigint
#  legacy_origin_id        :bigint
#  organization_id         :uuid
#  origin_id               :uuid
#  customer_id                 :uuid
#
# Indexes
#
#  index_booking_queries_on_company_id                           (company_id)
#  index_booking_queries_on_creator_id                           (creator_id)
#  index_booking_queries_on_destination_type_and_destination_id  (destination_type,destination_id)
#  index_booking_queries_on_legacy_destination                   (legacy_destination_type,legacy_destination_id)
#  index_booking_queries_on_legacy_origin                        (legacy_origin_type,legacy_origin_id)
#  index_booking_queries_on_organization_id                      (organization_id)
#  index_booking_queries_on_origin_type_and_origin_id            (origin_type,origin_id)
#  index_booking_queries_on_customer_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id)
#  fk_rails_...  (creator_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (customer_id => users_users.id)
#

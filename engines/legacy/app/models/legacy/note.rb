# frozen_string_literal: true

module Legacy
  class Note < ApplicationRecord
    self.table_name = "notes"

    acts_as_paranoid

    belongs_to :target, polymorphic: true, optional: true
    belongs_to :pricings_pricing, optional: true
    belongs_to :itinerary, optional: true, class_name: "Legacy::Itinerary"
    belongs_to :hub, optional: true, class_name: "Legacy::Hub"
    belongs_to :trucking_pricing, optional: true, class_name: "Legacy::TruckingPricing"
    belongs_to :organization, optional: true, class_name: "Organizations::Organization"

    validates :target, presence: true, unless: :attached_by_uuid

    def attached_by_uuid
      pricings_pricing_id.present? || organization_id.present?
    end
  end
end

# == Schema Information
#
# Table name: notes
#
#  id                  :bigint           not null, primary key
#  body                :string
#  contains_html       :boolean
#  deleted_at          :datetime
#  header              :string
#  level               :string
#  remarks             :boolean          default(FALSE), not null
#  target_type         :string
#  transshipment       :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  hub_id              :integer
#  itinerary_id        :integer
#  organization_id     :uuid
#  pricings_pricing_id :uuid
#  sandbox_id          :uuid
#  target_id           :integer
#  tenant_id           :integer
#  trucking_pricing_id :integer
#
# Indexes
#
#  index_notes_on_deleted_at                 (deleted_at)
#  index_notes_on_organization_id            (organization_id)
#  index_notes_on_pricings_pricing_id        (pricings_pricing_id)
#  index_notes_on_remarks                    (remarks)
#  index_notes_on_sandbox_id                 (sandbox_id)
#  index_notes_on_target_type_and_target_id  (target_type,target_id)
#  index_notes_on_transshipment              (transshipment)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#

# frozen_string_literal: true

module Legacy
  class Note < ApplicationRecord
    self.table_name = 'notes'

    belongs_to :target, polymorphic: true, optional: true
    belongs_to :pricings_pricing, optional: true
    belongs_to :itinerary, optional: true, class_name: 'Legacy::Itinerary'
    belongs_to :hub, optional: true, class_name: 'Legacy::Hub'
    belongs_to :trucking_pricing, optional: true, class_name: 'Legacy::TruckingPricing'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :tenant, optional: true, class_name: 'Legacy::Tenant'

    validates :target, presence: true, unless: :pricings_pricing_id
  end
end

# == Schema Information
#
# Table name: notes
#
#  id                           :bigint           not null, primary key
#  body(MASKED WITH literal:)   :string
#  contains_html                :boolean
#  header(MASKED WITH literal:) :string
#  level                        :string
#  remarks                      :boolean          default(FALSE), not null
#  target_type                  :string
#  transshipment                :boolean          default(FALSE), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  hub_id                       :integer
#  itinerary_id                 :integer
#  pricings_pricing_id          :uuid
#  sandbox_id                   :uuid
#  target_id                    :integer
#  tenant_id                    :integer
#  trucking_pricing_id          :integer
#
# Indexes
#
#  index_notes_on_pricings_pricing_id        (pricings_pricing_id)
#  index_notes_on_remarks                    (remarks)
#  index_notes_on_sandbox_id                 (sandbox_id)
#  index_notes_on_target_type_and_target_id  (target_type,target_id)
#  index_notes_on_transshipment              (transshipment)
#

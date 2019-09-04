# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :itinerary, optional: true
  belongs_to :hub, optional: true
  belongs_to :trucking_pricing, optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
end

# == Schema Information
#
# Table name: notes
#
#  id                  :bigint(8)        not null, primary key
#  itinerary_id        :integer
#  hub_id              :integer
#  trucking_pricing_id :integer
#  body                :string
#  header              :string
#  level               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  sandbox_id          :uuid
#  target_type         :string
#  target_id           :integer
#

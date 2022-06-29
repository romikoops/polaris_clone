# frozen_string_literal: true

module Journey
  class Addendum < ApplicationRecord
    belongs_to :shipment_request
    validates :label_name, presence: true, uniqueness: { scope: :shipment_request_id }
  end
end

# == Schema Information
#
# Table name: journey_addendums
#
#  id                  :uuid             not null, primary key
#  label_name          :string           not null
#  value               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  shipment_request_id :uuid
#
# Indexes
#
#  index_journey_addendums_on_shipment_request_id                 (shipment_request_id)
#  index_journey_addendums_on_shipment_request_id_and_label_name  (shipment_request_id,label_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (shipment_request_id => journey_shipment_requests.id)
#

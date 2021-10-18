# frozen_string_literal: true

module Journey
  class ShipmentRequest < ApplicationRecord
    belongs_to :result
    belongs_to :company, class_name: "Companies::Company"
    belongs_to :client, class_name: "Users::Client"
    has_many :documents
    has_many :contacts
    has_one :shipment

    accepts_nested_attributes_for :contacts

    enum status: {
      requested: "requested",
      in_progress: "in_progress",
      rejected: "rejected",
      completed: "completed"
    }
  end
end

# == Schema Information
#
# Table name: journey_shipment_requests
#
#  id                        :uuid             not null, primary key
#  commercial_value_cents    :integer
#  commercial_value_currency :string
#  notes                     :text
#  preferred_voyage          :string
#  status                    :enum
#  with_customs_handling     :boolean          default(FALSE)
#  with_insurance            :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  client_id                 :uuid
#  company_id                :uuid
#  result_id                 :uuid
#
# Indexes
#
#  index_journey_shipment_requests_on_client_id   (client_id)
#  index_journey_shipment_requests_on_company_id  (company_id)
#  index_journey_shipment_requests_on_result_id   (result_id)
#  index_journey_shipment_requests_on_status      (status)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (result_id => journey_results.id) ON DELETE => cascade
#

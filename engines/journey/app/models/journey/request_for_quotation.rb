# frozen_string_literal: true

module Journey
  class RequestForQuotation < ApplicationRecord
    validates :full_name, :phone, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email format" }, presence: true
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :query, class_name: "Journey::Query"
  end
end

# == Schema Information
#
# Table name: journey_request_for_quotations
#
#  id              :uuid             not null, primary key
#  company_name    :string
#  email           :string           not null
#  full_name       :string           not null
#  note            :text
#  phone           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  query_id        :uuid
#
# Indexes
#
#  index_journey_request_for_quotations_on_organization_id  (organization_id)
#  index_journey_request_for_quotations_on_query_id         (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (query_id => journey_queries.id)
#

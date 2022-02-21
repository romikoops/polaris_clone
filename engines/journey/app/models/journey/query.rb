# frozen_string_literal: true

module Journey
  class Query < ApplicationRecord
    has_many :cargo_units
    has_many :documents
    has_many :offers, inverse_of: :query
    has_many :results, dependent: :delete_all, inverse_of: :query
    has_many :result_errors, class_name: "Journey::Error"

    belongs_to :company, class_name: "Companies::Company", optional: true
    belongs_to :creator, polymorphic: true, optional: true
    belongs_to :client, class_name: "Users::Client", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :parent, class_name: "Journey::Query", optional: true

    has_one :profile, through: :client
    validates :source_id, presence: true
    validates :cargo_ready_date, presence: true
    validates :delivery_date, presence: true
    validates :destination, presence: true
    validates :destination_coordinates, presence: true
    validates :origin, presence: true
    validates :origin_coordinates, presence: true
    validates :load_type, presence: true

    validates :delivery_date, date: { after: :cargo_ready_date }
    validates :cargo_ready_date, date: { after_or_equal_to: proc { |obj| obj.created_at || Time.zone.now } }

    validate :updateable_attributes, on: :update

    enum status: {
      queued: "queued",
      running: "running",
      completed: "completed",
      failed: "failed"
    }

    enum load_type: {
      lcl: "lcl",
      fcl: "fcl"
    }

    def query_root
      current = self
      current = current.parent while current.parent.present?
      current
    end

    def updateable_attributes
      errors.add(:client_id, "Client id can only be added, not edited") if client_id_changed? && client_id_change_to_be_saved.first.present?
      errors.add(:creator_id, "Creator id can only be added, not edited") if creator_id_changed? && creator_id_change_to_be_saved.first.present?
      errors.add(:company_id, "Company id can only be added, not edited") if company_id_changed? && company_id_change_to_be_saved.first.present?
      errors.add(:base, "Client and Creator must be added together") if client_id_change_to_be_saved != creator_id_change_to_be_saved

      return if (changes_to_save.keys - %w[creator_id creator_type client_id company_id status]).empty?

      errors.add(:base, "Only status, client, company and creator can be updated")
    end
  end
end

# == Schema Information
#
# Table name: journey_queries
#
#  id                      :uuid             not null, primary key
#  billable                :boolean          default(FALSE)
#  cargo_ready_date        :datetime         not null
#  creator_type            :string
#  currency                :string
#  customs                 :boolean          default(FALSE)
#  delivery_date           :datetime         not null
#  destination             :string           not null
#  destination_coordinates :geometry         not null, geometry, 4326
#  insurance               :boolean          default(FALSE)
#  load_type               :enum             not null
#  origin                  :string           not null
#  origin_coordinates      :geometry         not null, geometry, 4326
#  status                  :enum
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_id               :uuid
#  company_id              :uuid
#  creator_id              :uuid
#  destination_geo_id      :string
#  organization_id         :uuid
#  origin_geo_id           :string
#  parent_id               :uuid
#  source_id               :uuid             not null
#
# Indexes
#
#  index_journey_queries_on_billable                     (billable)
#  index_journey_queries_on_client_id                    (client_id)
#  index_journey_queries_on_company_id                   (company_id)
#  index_journey_queries_on_creator_id_and_creator_type  (creator_id,creator_type)
#  index_journey_queries_on_organization_id              (organization_id)
#  index_journey_queries_on_parent_id                    (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#  fk_rails_...  (parent_id => journey_queries.id)
#

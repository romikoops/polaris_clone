# frozen_string_literal: true

module Journey
  class Query < ApplicationRecord
    has_many :cargo_units
    has_many :documents
    has_many :result_sets
    has_many :offers, inverse_of: :query

    belongs_to :company, class_name: "Companies::Company", optional: true
    belongs_to :creator, polymorphic: true, optional: true
    belongs_to :client, class_name: "Users::Client", optional: true
    belongs_to :organization, class_name: "Organizations::Organization"

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
    validates :cargo_ready_date, date: { after: proc { Time.zone.now } }

    enum load_type: {
      lcl: "lcl",
      fcl: "fcl"
    }

    def client
      super || Users::Client.new
    end

    def results
      return Journey::Result.none if result_sets.empty?

      result_sets.order(:created_at).last.results || []
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
#  customs                 :boolean          default(FALSE)
#  delivery_date           :datetime         not null
#  destination             :string           not null
#  destination_coordinates :geometry         not null, geometry, 4326
#  insurance               :boolean          default(FALSE)
#  load_type               :enum             not null
#  origin                  :string           not null
#  origin_coordinates      :geometry         not null, geometry, 4326
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_id               :uuid
#  company_id              :uuid
#  creator_id              :uuid
#  organization_id         :uuid
#  source_id               :uuid             not null
#
# Indexes
#
#  index_journey_queries_on_billable                     (billable)
#  index_journey_queries_on_client_id                    (client_id)
#  index_journey_queries_on_company_id                   (company_id)
#  index_journey_queries_on_creator_id_and_creator_type  (creator_id,creator_type)
#  index_journey_queries_on_organization_id              (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#

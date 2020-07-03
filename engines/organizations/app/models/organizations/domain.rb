# frozen_string_literal: true

module Organizations
  class Domain < ApplicationRecord
    belongs_to :organization

    validates :domain, presence: true, uniqueness: true, length: { maximum: 253 }
    validates :default, inclusion: { in: [true, false] }, uniqueness: { scope: :organization_id, if: :default? }

    scope :default, -> { find_by(default: true) }
  end
end

# == Schema Information
#
# Table name: organizations_domains
#
#  id              :uuid             not null, primary key
#  aliases         :string           is an Array
#  default         :boolean          default(FALSE), not null
#  domain          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_domains_on_domain           (domain) UNIQUE
#  index_organizations_domains_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#

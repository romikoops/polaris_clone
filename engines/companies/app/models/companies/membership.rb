# frozen_string_literal: true

# frozen_string_literal

module Companies
  class Membership < ApplicationRecord
    acts_as_paranoid

    belongs_to :company, class_name: "Companies::Company"
    belongs_to :client, class_name: "::Users::Client"
    belongs_to :member, polymorphic: true, optional: true

    validates :client_id, uniqueness: { scope: :company }
  end
end

# == Schema Information
#
# Table name: companies_memberships
#
#  id          :uuid             not null, primary key
#  deleted_at  :datetime
#  member_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  branch_id   :string
#  client_id   :uuid
#  company_id  :uuid
#  member_id   :uuid
#
# Indexes
#
#  companies_memberships_client_id                           (client_id) UNIQUE WHERE (deleted_at IS NULL)
#  index_companies_memberships_on_company_id                 (company_id)
#  index_companies_memberships_on_deleted_at                 (deleted_at)
#  index_companies_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => users_clients.id) ON DELETE => cascade
#  fk_rails_...  (company_id => companies_companies.id)
#

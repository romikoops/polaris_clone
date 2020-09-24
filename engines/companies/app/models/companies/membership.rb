# frozen_string_literal

module Companies
  class Membership < ApplicationRecord
    acts_as_paranoid

    belongs_to :company, class_name: "Companies::Company"
    belongs_to :member, polymorphic: true

    validates :member_id, uniqueness: { scope: :company }
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
#  company_id  :uuid
#  member_id   :uuid
#
# Indexes
#
#  index_companies_memberships_on_company_id                 (company_id)
#  index_companies_memberships_on_deleted_at                 (deleted_at)
#  index_companies_memberships_on_member_id_and_company_id   (member_id,company_id) UNIQUE
#  index_companies_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id)
#

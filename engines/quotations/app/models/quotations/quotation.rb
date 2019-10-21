# frozen_string_literal: true

module Quotations
  class Quotation < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :user, optional: true, class_name: 'Legacy::User'
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus'
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    has_many :tenders, inverse_of: :quotation

  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  user_id              :bigint
#  tenant_id            :uuid
#  origin_nexus_id      :integer
#  destination_nexus_id :integer
#  selected_date        :datetime
#  sandbox_id           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

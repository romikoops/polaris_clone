# frozen_string_literal: true

module Legacy
  class Tenant < ApplicationRecord
    self.table_name = 'tenants'

    has_many :users
    has_many :shipments

    has_paper_trail
  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint(8)        not null, primary key
#  theme       :jsonb
#  emails      :jsonb
#  subdomain   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  phones      :jsonb
#  addresses   :jsonb
#  name        :string
#  scope       :jsonb
#  currency    :string           default("EUR")
#  web         :jsonb
#  email_links :jsonb
#

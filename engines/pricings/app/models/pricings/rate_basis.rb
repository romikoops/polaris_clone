# frozen_string_literal: true

module Pricings
  class RateBasis < ApplicationRecord
    def self.get_internal_key(external_rate_basis)
      rate_basis = Pricings::RateBasis.find_by(external_code: external_rate_basis)
      rate_basis.nil? ? external_rate_basis : rate_basis.internal_code
    end

    def self.create_from_external_key(external_rate_basis)
      rate_basis = Pricings::RateBasis.find_by(external_code: external_rate_basis)
      rate_basis ||= Pricings::RateBasis.create(
        external_code: external_rate_basis,
        internal_code: external_rate_basis
      )

      rate_basis
    end
  end
end

# == Schema Information
#
# Table name: pricings_rate_bases
#
#  id            :uuid             not null, primary key
#  description   :string
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sandbox_id    :uuid
#
# Indexes
#
#  index_pricings_rate_bases_on_external_code  (external_code)
#  index_pricings_rate_bases_on_sandbox_id     (sandbox_id)
#

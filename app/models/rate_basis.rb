# frozen_string_literal: true

class RateBasis < ApplicationRecord
  def self.get_internal_key(external_rate_basis)
    rate_basis = RateBasis.find_by(external_code: external_rate_basis)
    rate_basis.nil? ? external_rate_basis : rate_basis.internal_code
  end
end

# == Schema Information
#
# Table name: rate_bases
#
#  id            :bigint(8)        not null, primary key
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

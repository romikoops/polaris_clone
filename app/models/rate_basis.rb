# frozen_string_literal: true

class RateBasis < Legacy::RateBasis
end

# == Schema Information
#
# Table name: rate_bases
#
#  id            :bigint           not null, primary key
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

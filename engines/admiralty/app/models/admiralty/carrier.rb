# frozen_string_literal: true

module Admiralty
  class Carrier < Routing::Carrier
    before_validation :downcase_code, on: :create
    after_validation :persist_legacy_carrier, on: :create

    def downcase_code
      code.downcase!
    end

    def persist_legacy_carrier
      Legacy::Carrier.create_with(name: name).find_or_initialize_by(code: code.downcase)
    end
  end
end

# == Schema Information
#
# Table name: routing_carriers
#
#  id               :uuid             not null, primary key
#  abbreviated_name :string
#  code             :string
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  routing_carriers_index  (name,code,abbreviated_name) UNIQUE
#

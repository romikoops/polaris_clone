# frozen_string_literal: true

module Api
  class Carrier < ::Legacy::Carrier
    self.inheritance_column = nil

    def routing_carrier
      @routing_carrier ||= Routing::Carrier.find_by(code: code)
    end

    delegate :logo, to: :routing_carrier
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint           not null, primary key
#  code       :string
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_carriers_on_code        (code) UNIQUE WHERE (deleted_at IS NULL)
#  index_carriers_on_sandbox_id  (sandbox_id)
#

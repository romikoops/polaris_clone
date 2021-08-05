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

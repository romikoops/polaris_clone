# frozen_string_literal: true

module Pricings
  class ManipulatorBreakdown
    attr_accessor :charge_category, :data, :cargo, :source, :order, :target, :delta,
      :applicable, :metadata
    delegate :applicable, :order, :operator, to: :source, allow_nil: true
    delegate :cargo_class, to: :cargo
    delegate :code, to: :charge_category

    def initialize(charge_category:, data:, delta:, source: nil, cargo: nil, metadata: {})
      @source = source
      @charge_category = charge_category
      @cargo = cargo
      @metadata = metadata
      @data = data
      @delta = delta
    end

    def target_name
      return applicable.try(:name) unless applicable.is_a?(Organizations::User)

      Profiles::ProfileService.fetch(user_id: applicable.id)&.full_name
    end
  end
end

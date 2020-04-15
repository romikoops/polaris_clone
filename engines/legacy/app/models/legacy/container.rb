# frozen_string_literal: true

module Legacy
  class Container < ApplicationRecord
    self.table_name = 'containers'

    TARE_WEIGHTS = {
      fcl_10: 1300,
      fcl_20: 2370,
      fcl_20_ot: 2400,
      fcl_20_rf: 3200,
      fcl_20_frs: 2530,
      fcl_20_frw: 2530,
      fcl_40: 3750,
      fcl_40_hq: 4590,
      fcl_40_ot: 3850,
      fcl_40_rf: 4900,
      fcl_40_hq_rf: 4500,
      fcl_40_frs: 5480,
      fcl_40_frw: 5480,
      fcl_45: 4000,
      fcl_45_hq: 4590,
      fcl_45_rf: 5200
    }.freeze

    PRICING_WEIGHT_STEPS = [28.0, 24.0, 18.0, 14.0, 5.0].freeze
    CARGO_CLASSES = TARE_WEIGHTS.keys.map(&:to_s)

    belongs_to :shipment, class_name: 'Legacy::Shipment'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    before_validation :set_gross_weight, :set_weight_class, :sync_cargo_class, :set_tare_weight

    validates :size_class, presence: true
    validates :weight_class, presence: true
    validates :payload_in_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :tare_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :gross_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def self.extract(containers_attributes)
      containers_attributes.map do |container_attributes|
        new(container_attributes)
      end
    end

    def size
      size_class.split('_').first
    end

    private

    def set_gross_weight
      self.gross_weight = (payload_in_kg || 0) + (tare_weight || 0)
    end

    def set_tare_weight
      self.tare_weight ||= TARE_WEIGHTS[size_class.to_sym] unless size_class.nil?
    end

    def set_weight_class
      return if weight_class.present?
      return if size_class.nil?

      which_weight_step = nil
      PRICING_WEIGHT_STEPS[1..-1].each_with_index do |weight_step, i|
        which_weight_step = PRICING_WEIGHT_STEPS[i] if payload_in_kg / 1000 > weight_step
      end
      which_weight_step = PRICING_WEIGHT_STEPS[-1] if which_weight_step.nil?
      which_weight_step = which_weight_step.to_d

      self.weight_class = "<= #{which_weight_step}t"
    end

    def sync_cargo_class
      self.cargo_class ||= size_class
      self.size_class  ||= cargo_class
    end
  end
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint           not null, primary key
#  cargo_class     :string
#  contents        :string
#  customs_text    :string
#  dangerous_goods :boolean
#  gross_weight    :decimal(, )
#  hs_codes        :string           default([]), is an Array
#  payload_in_kg   :decimal(, )
#  quantity        :integer
#  size_class      :string
#  tare_weight     :decimal(, )
#  unit_price      :jsonb
#  weight_class    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sandbox_id      :uuid
#  shipment_id     :integer
#
# Indexes
#
#  index_containers_on_sandbox_id  (sandbox_id)
#

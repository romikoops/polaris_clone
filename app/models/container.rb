# frozen_string_literal: true

require 'bigdecimal'
class Container < ApplicationRecord
  # The following Constants are currently being stored directly
  # in the Front End, but may be needed in future refactoring.
  #
  # DESCRIPTIONS         = ContainerLookups.get_descriptions
  # WEIGHTS              = ContainerLookups.get_weights
  TARE_WEIGHTS = {
    fcl_20:    2370,
    fcl_40:    3750,
    fcl_40_hq: 4000
  }.freeze
  PRICING_WEIGHT_STEPS = ContainerLookups.get_pricing_weight_steps

  belongs_to :shipment

  before_validation :set_gross_weight, :set_weight_class, :sync_cargo_class, :set_tare_weight

  validates :size_class,    presence: true
  validates :weight_class,  presence: true
  validates :payload_in_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tare_weight,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gross_weight,  presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Class methods
  def self.extract(containers_attributes)
    containers_attributes.map do |container_attributes|
      new(container_attributes)
    end
  end

  # Instance Methods
  def size
    size_class.split('_')[0]
  end

  private

  def set_gross_weight
    self.gross_weight = (payload_in_kg || 0) + (tare_weight || 0)
  end

  def set_tare_weight
    self.tare_weight ||= TARE_WEIGHTS[size_class.to_sym] unless size_class.nil?
  end

  def set_weight_class
    return unless weight_class.blank?
    return if size_class.nil?

    size = size_class.split('_').first
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

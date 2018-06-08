# frozen_string_literal: true

class ChargeCategory < ApplicationRecord
  has_many :charges

  validates :name, :code, presence: true
  validates :code, is_model: true, unless: ->(obj) { obj.cargo_unit_id.nil? }

  def self.grand_total
    find_or_create_by(code: "grand_total", name: "Grand Total")
  end

  def self.base_node
    find_or_create_by(code: "base_node", name: "Base Node")
  end

  def self.from_code(code)
    find_or_create_by(code: code, name: code.to_s.humanize.split(" ").map(&:capitalize).join(" "))
  end

  def cargo_unit
    return nil if cargo_unit_id.nil?

    klass = code.camelize.safe_constantize
    klass.where(id: cargo_unit_id).first
  end
end

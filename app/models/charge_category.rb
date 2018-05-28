class ChargeCategory < ApplicationRecord
  has_many :charges
  
  validates :name, :code, presence: true
  validates :code, is_model: true, unless: -> obj { obj.cargo_unit_id.nil? }

  def cargo_unit
    return nil if cargo_unit_id.nil?

    klass = code.camelize.safe_constantize
    klass.where(id: cargo_unit_id).first
  end
end

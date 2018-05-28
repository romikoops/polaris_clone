class Charge < ApplicationRecord
  has_one :price
  belongs_to :charge_category
  belongs_to :charge_breakdown
  belongs_to :parent, class: :charge_breakdown, optional: true
  has_many :charges, foreign_key: :parent_id
  before_validation :set_detail_level, on: :create

  validates :detail_level, presence: true

  def children
    charges
  end

  private

  def set_detail_level
    self.detail_level = ChargeDetailLevelCalculator.exec(self)
  end
end

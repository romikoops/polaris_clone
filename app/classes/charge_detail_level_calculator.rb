# frozen_string_literal: true

class ChargeDetailLevelCalculator
  def self.exec(charge, n=0)
    return n if charge.parent_id.nil?
    exec(charge.parent, n + 1)
  end
end

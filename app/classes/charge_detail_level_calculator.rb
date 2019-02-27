# frozen_string_literal: true

class ChargeDetailLevelCalculator
  def self.exec(charge, number = 0)
    return number if charge.parent_id.nil?

    exec(charge.parent, number + 1)
  end
end

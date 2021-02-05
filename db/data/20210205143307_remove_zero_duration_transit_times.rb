class RemoveZeroDurationTransitTimes < ActiveRecord::Migration[5.2]
  def up
    Legacy::TransitTime.where(duration: 0).destroy_all
  end
end

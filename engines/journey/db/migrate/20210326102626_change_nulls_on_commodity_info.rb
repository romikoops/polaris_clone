# frozen_string_literal: true

class ChangeNullsOnCommodityInfo < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      change_column_null :journey_commodity_infos, :hs_code, true
      change_column_null :journey_commodity_infos, :imo_class, true

      change_column_default :journey_commodity_infos, :hs_code, nil
      change_column_default :journey_commodity_infos, :imo_class, nil
    end
  end
end

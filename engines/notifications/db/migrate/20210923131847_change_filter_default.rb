# frozen_string_literal: true

class ChangeFilterDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:notifications_subscriptions, :filter, {})
  end
end

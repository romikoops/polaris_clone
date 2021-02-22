# frozen_string_literal: true
class AddIndexToCreatorId < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :quotations_quotations, :users_users, column: :creator_id, validate: false
  end
end

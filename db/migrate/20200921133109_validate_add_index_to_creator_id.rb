class ValidateAddIndexToCreatorId < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :quotations_quotations, :users_users
  end
end

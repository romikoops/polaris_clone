# frozen_string_literal: true

class AddDefaultValueToScope < ActiveRecord::Migration[5.2]
  def change
    change_column_default :organizations_scopes, :content, from: nil, to: {}
  end
end

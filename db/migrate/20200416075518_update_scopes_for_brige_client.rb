# frozen_string_literal: true

class UpdateScopesForBrigeClient < ActiveRecord::Migration[5.2]
  def change
    Doorkeeper::Application.where("name LIKE 'bridge%'").update(scopes: 'admin public')
  end
end

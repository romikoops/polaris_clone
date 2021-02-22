# frozen_string_literal: true
class AddDipperToDoorkeeperApplications < ActiveRecord::Migration[5.2]
  def up
    Doorkeeper::Application.create!(name: "dipper", scopes: "admin public", redirect_uri: "https://demo.itsmycargo.com")
  end
end

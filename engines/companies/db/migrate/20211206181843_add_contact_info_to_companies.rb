# frozen_string_literal: true

class AddContactInfoToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies_companies, :contact_person_name, :string
    add_column :companies_companies, :contact_email, :string
    add_column :companies_companies, :contact_phone, :string
    add_column :companies_companies, :registration_number, :string
  end
end

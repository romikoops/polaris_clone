# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Profile, type: :model do
  it 'builds a valid object' do
    expect(FactoryBot.build(:profiles_profile)).to be_valid
  end
end

# == Schema Information
#
# Table name: profiles_profiles
#
#  id           :uuid             not null, primary key
#  company_name :string
#  first_name   :string
#  image        :string
#  last_name    :string
#  phone        :string
#  user_id      :uuid
#
# Indexes
#
#  index_profiles_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => tenants_users.id)
#

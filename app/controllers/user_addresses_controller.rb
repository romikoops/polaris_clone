# frozen_string_literal: true

class UserAddressesController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    user = User.find(params[:user_id])
    resp = Address.all_with_primary_for(user)

    response_handler(resp)
  end

  def create
    user = User.find(params[:user_id])
    address = Address.create_from_raw_params!(JSON.parse(params[:new_address]))
    new_user_loc = user.user_addresses.create!(primary: false, address_id: address.id)
    resp = []
    user_locs = user.user_addresses
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def update
    user = User.find(params[:user_id])
    primary_uls = user.user_addresses.where(primary: true)
    primary_uls.each do |ul|
      ul.update_attribute(:primary, false)
    end

    ul = UserAddress.find_by(user_id: params[:user_id], address_id: params[:id])
    ul.update_attribute(:primary, true)
    resp = []
    user_locs = user.user_addresses
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def edit
    user = User.find(params[:user_id])
    address_data = JSON.parse(params[:edit_address])
    address_data.delete('id')
    address_data['country'] = Country.geo_find_by_name(address_data['country'])
    user_loc = Address.find(params[:address_id])
    user_loc.update_attributes(address_data)
    user_loc.save!
    resp = []
    user_locs = user.user_addresses
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def destroy
    ul = UserAddress.find_by(user_id: params[:user_id], address_id: params[:id])
    ul.destroy

    response_handler(id: params[:id])
  end
end

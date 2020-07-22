# frozen_string_literal: true

class UserAddressesController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    user = Organizations::User.find(params[:user_id])
    user_addresses = addresses_for_user(user: user)
    resp = user_addresses.map do |user_address|
      loc = user_address.address
      prim = { primary: loc.primary_for?(user) }
      loc.to_custom_hash.merge(prim)
    end

    response_handler(resp)
  end

  def create
    user = Organizations::User.find_by(id: params[:user_id])
    user_addresses = addresses_for_user(user: user)
    address = Address.create_from_raw_params!(JSON.parse(params[:new_address]))
    user_addresses.create!(primary: false, address_id: address.id)
    resp = []
    user_locs = user_addresses
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def update
    user = Organizations::User.find_by(id: params[:user_id])
    user_addresses = addresses_for_user(user: user)
    primary_uls = user_addresses.where(primary: true)
    primary_uls.each do |ul|
      ul.update_attribute(:primary, false)
    end

    ul = UserAddress.find_by(user_id: params[:user_id], address_id: params[:id])
    ul.update_attribute(:primary, true)
    resp = []
    user_locs = user_addresses
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def edit
    user = Organizations::User.find_by(id: params[:user_id])
    user_addresses = addresses_for_user(user: user)
    address_data = JSON.parse(params[:edit_address])
    address_data.delete('id')
    address_data['country'] = Country.geo_find_by_name(address_data['country'])
    user_loc = Address.find_by(id: params[:address_id])
    user_loc.update_attributes(address_data)
    user_loc.save!
    resp = []
    user_locs = user_addresses
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

  def addresses_for_user(user:)
     Legacy::UserAddress.where(user_id: user.id)
  end
end

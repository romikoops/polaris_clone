# frozen_string_literal: true

class UserAddressesController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    user = Users::Client.find(params[:user_id])
    user_addresses = addresses_for_user(user: user)
    resp = user_addresses.map { |user_address|
      loc = user_address.address
      prim = {primary: loc.primary_for?(user)}
      loc.to_custom_hash.merge(prim)
    }

    response_handler(resp)
  end

  def create
    user = Users::Client.find_by(id: params[:user_id])
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
    user = Users::Client.find_by(id: params[:user_id])
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
    user = Users::Client.find_by(id: params[:user_id])
    user_addresses = addresses_for_user(user: user)
    address_data = JSON.parse(params[:edit_address])
    address_data.delete("id")
    address_data["country"] = Country.geo_find_by_name(address_data["country"])
    user_loc = Address.find_by(id: params[:address_id])
    user_loc.update(address_data)
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

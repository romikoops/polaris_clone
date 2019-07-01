# frozen_string_literal: true

class UserAddressesController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    user = User.find_by(id: params[:user_id], sandbox: @sandbox)
    resp = user.addresses.map do |loc|
      prim = { primary: loc.primary_for?(user) }
      loc.to_custom_hash.merge(prim)
    end

    response_handler(resp)
  end

  def create
    user = User.find_by(id: params[:user_id], sandbox: @sandbox)
    address = Address.create_from_raw_params!(JSON.parse(params[:new_address].merge(sandbox: @sandbox)))
    user.user_addresses.create!(primary: false, address_id: address.id, sandbox: @sandbox)
    resp = []
    user_locs = user.user_addresses.where(sandbox: @sandbox)
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def update
    user = User.find_by(id: params[:user_id], sandbox: @sandbox)
    primary_uls = user.user_addresses.where(primary: true, sandbox: @sandbox)
    primary_uls.each do |ul|
      ul.update_attribute(:primary, false)
    end

    ul = UserAddress.find_by(user_id: params[:user_id], address_id: params[:id], sandbox: @sandbox)
    ul.update_attribute(:primary, true)
    resp = []
    user_locs = user.user_addresses.where(sandbox: @sandbox)
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def edit
    user = User.find_by(id: params[:user_id], sandbox: @sandbox)
    address_data = JSON.parse(params[:edit_address])
    address_data.delete('id')
    address_data['country'] = Country.geo_find_by_name(address_data['country'])
    user_loc = Address.find_by(id: params[:address_id], sandbox: @sandbox)
    user_loc.update_attributes(address_data)
    user_loc.save!
    resp = []
    user_locs = user.user_addresses.where(sandbox: @sandbox)
    user_locs.each do |ul|
      resp.push(user: ul, address: ul.address.to_custom_hash)
    end
    response_handler(resp)
  end

  def destroy
    ul = UserAddress.find_by(user_id: params[:user_id], address_id: params[:id], sandbox: @sandbox)
    ul.destroy

    response_handler(id: params[:id])
  end
end

# frozen_string_literal: true

class IncotermLiability < ApplicationRecord
  has_many :incoterms
  def self.create_all!
    [true, false].repeated_permutation(4).to_a.each do |values|
      attributes = IncotermLiability.given_attribute_names.zip(values).to_h
      IncotermLiability.find_or_create_by!(attributes)
    end
  end
end

# == Schema Information
#
# Table name: incoterm_liabilities
#
#  id                       :bigint(8)        not null, primary key
#  pre_carriage             :boolean
#  on_carriage              :boolean
#  freight                  :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  origin_warehousing       :boolean
#  origin_labour            :boolean
#  origin_packing           :boolean
#  origin_loading           :boolean
#  origin_customs           :boolean
#  origin_port_charges      :boolean
#  forwarders_fee           :boolean
#  origin_vessel_loading    :boolean
#  destination_port_charges :boolean
#  destination_customs      :boolean
#  destination_loading      :boolean
#  destination_labour       :boolean
#  destination_warehousing  :boolean
#

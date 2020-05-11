# frozen_string_literal: true

class Vehicle < Legacy::Vehicle
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

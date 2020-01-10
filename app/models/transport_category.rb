# frozen_string_literal: true

class TransportCategory < Legacy::TransportCategory
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  vehicle_id        :integer
#  mode_of_transport :string
#  name              :string
#  cargo_class       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  load_type         :string
#  sandbox_id        :uuid
#

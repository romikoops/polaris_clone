# frozen_string_literal: true

module Legacy
  class MandatoryCharge < ApplicationRecord
    self.table_name = 'mandatory_charges'
    has_many :hubs
  end
end

# == Schema Information
#
# Table name: mandatory_charges
#
#  id             :bigint           not null, primary key
#  pre_carriage   :boolean
#  on_carriage    :boolean
#  import_charges :boolean
#  export_charges :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# frozen_string_literal: true

class MandatoryCharge < ApplicationRecord
  has_paper_trail
  has_many :hubs

  scope :falsified, -> {
                      find_by(
                        pre_carriage: false,
                        on_carriage: false,
                        import_charges: false,
                        export_charges: false
                      )
                    }

  def self.create_all!
    [true, false].repeated_permutation(4).to_a.each do |values|
      attributes = MandatoryCharge.given_attribute_names.zip(values).to_h
      MandatoryCharge.find_or_create_by!(attributes)
    end
  end
end

# == Schema Information
#
# Table name: mandatory_charges
#
#  id             :bigint(8)        not null, primary key
#  pre_carriage   :boolean
#  on_carriage    :boolean
#  import_charges :boolean
#  export_charges :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

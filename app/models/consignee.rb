class Consignee < ActiveRecord::Base
  has_many :shipments
  belongs_to :location
  has_many :shippers, through: :contacts, class_name: "User"

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_company
    "#{first_name} #{last_name}, #{company_name}"
  end

  def full_name_and_company_and_address
    "#{first_name} #{last_name}\n#{company_name}\n#{location.geocoded_address}"
  end
end

# frozen_string_literal: true

module Legacy
  class LocalCharge < ApplicationRecord
    self.table_name = 'local_charges'
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle', optional: true
    belongs_to :counterpart_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new("(#{arel_table[:effective_date].name}, #{arel_table[:expiration_date].name})"),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)

    def hub_name
      hub&.name
    end

    def counterpart_hub_name
      counterpart_hub&.name
    end

    def carrier_name
      tenant_vehicle&.carrier&.name
    end

    def service_level
      tenant_vehicle&.name
    end
  end
end

# == Schema Information
#
# Table name: local_charges
#
#  id                 :bigint(8)        not null, primary key
#  mode_of_transport  :string
#  load_type          :string
#  hub_id             :integer
#  tenant_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tenant_vehicle_id  :integer
#  counterpart_hub_id :integer
#  direction          :string
#  fees               :jsonb
#  dangerous          :boolean          default(FALSE)
#  effective_date     :datetime
#  expiration_date    :datetime
#  user_id            :integer
#  uuid               :uuid
#  sandbox_id         :uuid
#  group_id           :uuid
#  internal           :boolean          default(FALSE)
#

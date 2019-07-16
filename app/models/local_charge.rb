# frozen_string_literal: true

class LocalCharge < Legacy::LocalCharge
  has_paper_trail
  belongs_to :hub
  belongs_to :tenant
  belongs_to :tenant_vehicle, optional: true
  belongs_to :counterpart_hub, class_name: 'Hub', optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  before_validation -> { self.uuid ||= SecureRandom.uuid }, on: :create

  scope :for_load_type, ->(load_type) { where(load_type: load_type.downcase) }
  scope :for_mode_of_transport, ->(mot) { where(mode_of_transport: mot.downcase) }
  scope :for_dates, (lambda do |start_date, end_date|
    where(Arel::Nodes::InfixOperation.new(
            'OVERLAPS',
            Arel::Nodes::SqlLiteral.new("(#{arel_table[:effective_date].name}, #{arel_table[:expiration_date].name})"),
            Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
          ))
  end)
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
#

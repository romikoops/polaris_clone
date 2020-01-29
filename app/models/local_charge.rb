# frozen_string_literal: true

class LocalCharge < Legacy::LocalCharge
  has_paper_trail
  belongs_to :hub
  belongs_to :tenant
  belongs_to :tenant_vehicle, optional: true
  belongs_to :counterpart_hub, class_name: 'Hub', optional: true
  has_many :notes, dependent: :destroy, as: :target
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  before_validation -> { self.uuid ||= SecureRandom.uuid }, on: :create

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
#  id                 :bigint           not null, primary key
#  dangerous          :boolean          default(FALSE)
#  direction          :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  fees               :jsonb
#  internal           :boolean          default(FALSE)
#  load_type          :string
#  metadata           :jsonb
#  mode_of_transport  :string
#  uuid               :uuid
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  group_id           :uuid
#  hub_id             :integer
#  sandbox_id         :uuid
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#  user_id            :integer
#
# Indexes
#
#  index_local_charges_on_sandbox_id  (sandbox_id)
#  index_local_charges_on_tenant_id   (tenant_id)
#  index_local_charges_on_uuid        (uuid) UNIQUE
#

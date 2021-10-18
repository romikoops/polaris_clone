# frozen_string_literal: true

class LocalChargesRemoveDuplicatesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    total organizations.count
    generate_upsert_ids_on_local_charges
    destroy_duplicated_local_charges
  end

  private

  def organizations
    @organizations ||= Organizations::Organization.all
  end

  def generate_upsert_ids_on_local_charges
    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE local_charges
        SET uuid = uuid_generate_v5('#{Legacy::LocalCharge::UUID_V5_NAMESPACE}', CONCAT(hub_id::text, counterpart_hub_id::text, tenant_vehicle_id::text, load_type::text, mode_of_transport::text, group_id::text, direction::text, organization_id::text)::text)
      SQL
    )
  end

  def destroy_duplicated_local_charges
    organizations.find_each.with_index do |org, index|
      at index + 1
      at index, "Organization: #{org.slug}"
      duplicated_local_charges = duplicates(organization: org)
      next if duplicated_local_charges.empty?

      local_charge_pairs = duplicated_local_charges.select(:uuid, :organization_id).distinct
      destroy_records_from(local_charge_pairs: local_charge_pairs, duplicates: duplicated_local_charges)
      at index, "Local charges completed"
    end
  end

  def duplicates(organization:)
    Legacy::LocalCharge.where(organization: organization).where(
      "(select count(*) from local_charges inr
      WHERE inr.uuid = local_charges.uuid
      AND inr.validity && local_charges.validity
      ) > 1"
    )
  end

  def destroy_records_from(local_charge_pairs:, duplicates:)
    local_charge_pairs.each do |record|
      invalid_local_charges = find_invalid_local_charges(duplicates: duplicates, record: record)
      invalid_local_charges.each_with_index do |local_charge, index|
        previous_local_charge = invalid_local_charges[index - 1]
        next unless previous_local_charge
        next local_charge.destroy if previous_local_charge.effective_date <= local_charge.effective_date

        next unless previous_local_charge.validity.cover?(local_charge.validity) || local_charge.validity.cover?(previous_local_charge.validity)

        local_charge.update(expiration_date: (previous_local_charge.effective_date - 1.day).end_of_day)
      end
    end
  end

  def find_invalid_local_charges(duplicates:, record:)
    duplicates.where(
      uuid: record.uuid,
      organization_id: record.organization_id
    ).order(created_at: :desc)
  end
end

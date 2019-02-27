# frozen_string_literal: true

class HubNexusMatchValidator < ActiveModel::Validator
  def validate(record)
    %w(origin destination).each do |target|
      next unless has_hub?(record, target) && has_nexus?(record, target)

      if hub(record, target).nexus_id != nexus_id(record, target)
        message = "belongs to a nexus that does not match the shipment's #{target} nexus"
        record.errors["#{target}_hub_id"] << message
      end
    end
  end

  private

  def hub_id(record, target)
    record["#{target}_hub_id"]
  end

  def nexus_id(record, target)
    record["#{target}_nexus_id"]
  end

  def hub(record, target)
    Hub.find(hub_id(record, target))
  end

  def has_hub?(record, target)
    !!hub_id(record, target)
  end

  def has_nexus?(record, target)
    !!nexus_id(record, target)
  end
end

# frozen_string_literal: true

class BackfillHubTypeWithValidMotWorker
  include Sidekiq::Worker

  TRUCKING_NAMES = %w[road trucking].freeze
  FailedHubTypeBackFill = Class.new(StandardError)
  def perform
    hubs_with_invalid_hub_type.find_each do |invalid_hub|
      if invalid_hub.hub_type.blank? || duplicate?(hub: invalid_hub)
        invalid_hub.destroy!
      elsif TRUCKING_NAMES.include?(invalid_hub.hub_type)
        invalid_hub.hub_type = "truck"
        invalid_hub.save!
      end
    end

    raise FailedHubTypeBackFill if hubs_with_invalid_hub_type.present?
  end

  private

  def duplicate?(hub:)
    Hub.where(
      nexus_id: hub.nexus_id,
      name: hub.name,
      terminal: hub.terminal,
      organization: hub.organization
    ).where.not(hub_type: hub.hub_type).present?
  end

  def hubs_with_invalid_hub_type
    Hub.where.not(hub_type: Legacy::Hub::MOT_HUB_NAME.keys)
  end
end

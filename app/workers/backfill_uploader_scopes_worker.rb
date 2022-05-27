# frozen_string_literal: true

class BackfillUploaderScopesWorker
  include Sidekiq::Worker

  def perform
    Organizations::Scope.find_each do |record|
      next if record.v2_uploaders.blank?

      record.content["uploader"] = record.content["v2_uploaders"].each_with_object({}) do |(key, value), hash|
        hash[key.to_s] = value ? "v3" : "legacy"
      end
      record.save!
    end
  end
end

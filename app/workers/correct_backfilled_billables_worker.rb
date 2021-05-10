# frozen_string_literal: true

class CorrectBackfilledBillablesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    Organizations::Organization.find_each.with_index do |organization, index|
      at index + 1, "Updating #{organization.slug}"

      validity_data = validity_lookup[organization.slug]
      # rubocop:disable Rails/SkipsModelValidations
      if validity_data.present?
        Journey::Query.where(organization: organization)
          .where.not("created_at::date >= ? AND created_at::date <= ?", validity_data["start"], validity_data["end"])
          .update_all(billable: false)
      else
        Journey::Query.where(organization: organization).update_all(billable: false)
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def validity_lookup
    {
      "normanglobal" => { "start" => Date.parse("2019-02-01"), "end" =>	Date.parse("2020-02-01") },
      "7connetwork" => { "start" => Date.parse("2020-11-01"), "end" =>	Date.parse("2021-09-22") },
      "unsworth" => { "start" => Date.parse("2020-07-01"), "end" =>	Time.zone.tomorrow },
      "freightright" => { "start" => Date.parse("2019-12-01"), "end" =>	Date.parse("2020-12-01") },
      "shipfreightto" => { "start" => Date.parse("2020-01-01"), "end" =>	Date.parse("2021-01-01") },
      "fivestar" => { "start" => Date.parse("2019-02-01"), "end" =>	Time.zone.tomorrow },
      "fivestar-nl" => { "start" =>	Date.parse("2020-08-01"), "end" => Time.zone.tomorrow	},
      "fivestar-be" => { "start" =>	Date.parse("2020-08-01"), "end" =>	Time.zone.tomorrow },
      "berkman" => { "start" => Date.parse("2020-02-01"), "end" =>	Date.parse("2021-02-01") },
      "gateway" => { "start" => Date.parse("2019-02-01"), "end" =>	Time.zone.tomorrow },
      "ssc" => { "start" => Date.parse("2020-12-01"), "end" => Time.zone.tomorrow	},
      "saco" => { "start" => Date.parse("2020-02-17"), "end" =>	Time.zone.tomorrow },
      "racingcargo" => { "start" => Date.parse("2020-08-01"), "end" =>	Time.zone.tomorrow }
    }
  end
end

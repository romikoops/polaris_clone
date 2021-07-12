# frozen_string_literal: true

module Admiralty
  # This Admiralty Country model serves to let us know wheteher there are location data in the data hub bucket for use in Trucking
  class Country < Legacy::Country
    def locations_enabled?
      bucket_object.exists?
    end

    def bucket_object
      bucket.object(csv_path)
    end

    def csv_path
      "#{Settings.geodata.path}/#{code}.csv"
    end

    def bucket
      @bucket ||= Aws::S3::Resource.new.bucket("itsmycargo-datahub")
    end
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string
#  flag       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

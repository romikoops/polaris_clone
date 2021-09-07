# frozen_string_literal: true

module Api
  module UploadPipelines
    class Okargo < Api::UploadPipelines::Airflow
      def perform
        s3_upload

        # disable the job scheduler temporarily in production, without breaking tests
        schedule_dag_run unless Rails.env.production?
      end

      private

      def dag_name
        "ingest_okargo_v1"
      end
    end
  end
end

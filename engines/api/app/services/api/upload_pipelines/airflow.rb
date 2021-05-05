# frozen_string_literal: true

module Api
  module UploadPipelines
    class Airflow < Api::UploadPipelines::Base
      def perform
        s3_upload && schedule_dag_run
      end

      def message
        "File uploaded and transformation job scheduled."
      end

      private

      def s3_upload
        response = Aws::S3::Client.new.put_object(
          bucket: Settings.aws.ingest_bucket,
          content_type: file_wrapper.content_type,
          key: s3_key,
          body: file_wrapper.file_or_string
        )

        response.etag.present? || (raise Aws::S3::Errors::ServiceError.new("etag is missing", nil))
      end

      def s3_key
        @s3_key ||= "#{organization_id}/#{file_wrapper.filename}"
      end

      def schedule_dag_run
        Api::AirflowDagRunJob.perform_later(dag_name: dag_name, payload: payload)
      end

      def dag_name
        raise NotImplementedError
      end

      def payload
        @payload ||= { conf: { organization_id: organization_id, s3_key: s3_key } }.to_json
      end
    end
  end
end

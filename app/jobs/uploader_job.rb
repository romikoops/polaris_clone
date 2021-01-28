class UploaderJob < ApplicationJob
  queue_as :default

  def perform(document_id:, options:)
    document = Legacy::File.find(document_id)
    organization = document.organization

    return if document.created_at < latest_created_at(organization: organization, doc_type: document.doc_type)

    user = Users::User.find(options[:user_id])
    options = {
      organization: organization,
      options: options.merge({user: user})
    }
    result = Processor.new(blob: document.file.blob).process { |file|
      ExcelDataServices::Loaders::Uploader.new(options.merge(file_or_path: file)).perform
    }

    UploadMailer
      .with(
        user_id: user.id,
        organization: organization,
        result: JSON.parse(result.to_json),
        file: document.file.blob.filename.sanitized
      )
      .complete_email
      .deliver_later

    result
  end

  private

  def latest_created_at(organization:, doc_type:)
    Legacy::File
      .where(organization: organization, doc_type: doc_type)
      .order(:created_at)
      .last
      .created_at
  end

  class Processor
    include ActiveStorage::Downloading

    attr_reader :blob

    def initialize(blob:)
      @blob = blob
    end

    def process
      Tempfile.create(["", blob.filename.extension_with_delimiter]) do |file|
        file.binmode
        file.write(blob.download)
        file.rewind

        yield file
      end
    end
  end
end

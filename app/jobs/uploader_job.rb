class UploaderJob < ApplicationJob
  queue_as :default

  def perform(document_id:, options:)
    user = Users::User.find(options[:user_id])
    document = Legacy::File.find(document_id)

    options = {
      organization: document.organization,
      options: options.merge({user: user})
    }

    result = Processor.new(blob: document.file.blob).process { |file|
      ExcelDataServices::Loaders::Uploader.new(options.merge(file_or_path: file)).perform
    }

    UploadMailer
      .with(
        user_id: user.id,
        organization: document.organization,
        result: JSON.parse(result.to_json),
        file: document.file.blob.filename.sanitized
      )
      .complete_email
      .deliver_later

    result
  end

  private

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

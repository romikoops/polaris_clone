# frozen_string_literal: true

class BackfillDocuments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    ActiveStorage::Attachment.where(
      record_type: ['Legacy::Document', 'Document', 'Content'],
      new_record_id: nil
    ).in_batches.each_record do |attachment|
      record = attachment.record_type.constantize.find_by(id: attachment.record_id)
      next if record.nil?

      if record.is_a? Content
        Legacy::Content.create(record.attributes).tap do |content|
          attachment.update(new_record_id: content.id, new_record_type: 'Legacy::Content')
        end
      else
        Legacy::File.create(record.attributes).tap do |file|
          attachment.update(new_record_id: file.id, new_record_type: 'Legacy::File')
        end
      end
    end
    ActiveStorage::Attachment.where(new_record_type: nil).delete_all
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :journey_document, class: "Journey::Document", traits: [:commercial_invoice] do
    association :query, factory: :journey_query
    association :shipment_request, factory: :journey_shipment_request

    trait :commercial_invoice do
      kind { :commercial_invoice }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/commercial_invoice.pdf", __dir__), "application/pdf") }
    end

    trait :dock_receipt do
      kind { :dock_receipt }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/dock_receipt.pdf", __dir__), "application/pdf") }
    end

    trait :bill_of_lading do
      kind { :bill_of_lading }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/bill_of_lading.pdf", __dir__), "application/pdf") }
    end

    trait :certificate_of_origin do
      kind { :certificate_of_origin }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/certificate_of_origin.pdf", __dir__), "application/pdf") }
    end

    trait :warehouse_receipt do
      kind { :warehouse_receipt }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/warehouse_receipt.pdf", __dir__), "application/pdf") }
    end

    trait :inspection_certificate do
      kind { :inspection_certificate }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/inspection_certificate.pdf", __dir__), "application/pdf") }
    end

    trait :export_license do
      kind { :export_license }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/export_license.pdf", __dir__), "application/pdf") }
    end

    trait :packing_list do
      kind { :packing_list }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/packing_list.pdf", __dir__), "application/pdf") }
    end

    trait :health_certificate do
      kind { :health_certificate }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/health_certificate.pdf", __dir__), "application/pdf") }
    end

    trait :insurance_certificate do
      kind { :insurance_certificate }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/insurance_certificate.pdf", __dir__), "application/pdf") }
    end

    trait :consular_documents do
      kind { :consular_documents }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/consular_documents.pdf", __dir__), "application/pdf") }
    end

    trait :free_trade_document do
      kind { :free_trade_document }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/free_trade_document.pdf", __dir__), "application/pdf") }
    end

    trait :shippers_letter_of_instruction do
      kind { :shippers_letter_of_instruction }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/shippers_letter_of_instruction.pdf", __dir__), "application/pdf") }
    end

    trait :destination_control_statement do
      kind { :destination_control_statement }
      file { Rack::Test::UploadedFile.new(File.expand_path("../fixtures/destination_control_statement.pdf", __dir__), "application/pdf") }
    end
  end
end

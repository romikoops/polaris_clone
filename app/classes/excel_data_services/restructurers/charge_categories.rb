# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class ChargeCategories < ExcelDataServices::Restructurers::Base
      def perform
        { 'ChargeCategories' => data[:rows_data] }
      end
    end
  end
end

# frozen_string_literal: true

module ExcelTool
  class RawIgs < ExcelTool::BaseTool # rubocop:disable Metrics/ClassLength
    include WritingTool
    attr_reader :user
    def post_initialize(_args)
      @row_data = []
      @sorted_data = []
      @filename         = 'schryver_sorted_raw_data.xlsx'
      @directory        = "tmp/#{@filename}"
      @header_values    = new_sheet_headers
      @workbook         = create_workbook(@directory)
      @first_sheet
    end

    def perform
      load_data
      sort_data
      write_data
    end

    private

    def load_data
      xlsx.sheets.each do |sheet_name|
        @first_sheet = xlsx.sheet(sheet_name)
        i = 2
        while i < @first_sheet.last_row
          @row_data << row_to_data(@first_sheet, i)
          i += 1
        end
      end
      @row_data.compact!
    end

    def row_to_data(sheet, row_nr, hide_name = false) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      row = sheet.row(row_nr)
      return nil unless row[3].include?('HH')

      p_code = if row[0].to_s.length < 5
                 '0' * (5 - row[0].to_s.length) + row[0].to_s
               else
                 row[0].to_s
               end
      {
        row_nr: row.nr,
sheet_name: sheet_name,
        postal_code: p_code,
        place_name: hide_name ? '' : row[1],
        harbour: row[3],
        fcl_20: {
          small: row[4],
          medium: row[5],
          large: row[6]
        },
        fcl_40: {
          small: row[7],
          large: row[8]
        },
        fcl_40_hq: {
          small: row[7],
          large: row[8]
        }
      }
    end

    def sort_data # rubocop:disable Metrics/AbcSize
      name_only_row_nrs = []
      rejected_row_nrs = []
      name_only_data = @row_data.group_by { |row| row[:place_name] }
      name_only_data.each do |_name, name_values|
        next unless name_values.length > 1

        postal_name_groups = name_values.group_by { |nv| nv[:postal_code] }
        png_values = postal_name_groups.values
        next unless png_values.length > 1

        png_values.each do |png_array|
          v = png_array.max { |a, b| a[:fcl_20][:small] <=> b[:fcl_20][:small] }
          name_only_row_nrs << v[:row_nr]
          png_array.reject { |z| z[:row_nr] == v[:row_nr] }.each { |y| rejected_row_nrs << y[:row_nr] }
        end
      end
      rows_to_ignore = name_only_row_nrs | rejected_row_nrs
      grouped_data = @row_data
                     .reject { |row| rows_to_ignore.include?(row[:row_nr]) }
                     .group_by { |row| [row[:postal_code], row[:place_name]].join('-') }
      grouped_data.each do |_key, values|
        @sorted_data << values.max { |a, b| a[:fcl_20][:small] <=> b[:fcl_20][:small] }
      end

      name_only_row_nrs.each do |row_nr|
        @sorted_data << row_to_data(@first_sheet, row_nr, true)
      end
    end

    def write_data
      workbook_hash = add_worksheet_to_workbook(@workbook, @header_values)
      @workbook = workbook_hash[:workbook]
      worksheet = workbook_hash[:worksheet]
      row = 1
      @sorted_data.each do |value|
        data = prep_row_data(value)
        worksheet = write_to_sheet(worksheet, row, 0, data)
        row += 1
      end
      @workbook.close
    end

    def prep_row_data(value)
      [
        [value[:postal_code].to_s, value[:place_name]].join(' - '),
        value[:postal_code].to_s,
        value[:place_name],
        value[:fcl_20][:small],
        value[:fcl_20][:medium],
        value[:fcl_20][:large],
        value[:fcl_40][:small],
        value[:fcl_40][:large],
        value[:fcl_40_hq][:small],
        value[:fcl_40_hq][:large]
      ]
    end

    def new_sheet_headers
      %w(POSTAL_CITY POSTAL_CODE PLACE 20_SMALL 20_MEDIUM 20_LARGE 40_SMALL 40_MEDIUM 40_HQ_SMALL 40_HQ_LARGE)
    end
  end
end

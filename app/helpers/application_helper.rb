# frozen_string_literal: true

module ApplicationHelper
  include FontAwesome::Rails::IconHelper

  def asset_data_base64(path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    data = Base64.encode64(asset.to_s).gsub(/\s+/, '')
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(data)}"
  end

  def format_to_price(*args)
    # There are 3 ways of calling this helper:
    #
    #    1. format_to_price({
    #         "value"    => 1.231234,
    #         "currency" => "EUR"
    #       })                                 #=> "1.23 EUR"
    #
    #    2. format_to_price(2.231234, "EUR")   #=> "1.23 EUR"
    #
    #    3. format_to_price(2.231234)          #=> "1.23"

    price, currency = args

    if valid_price_hash?(args)
      price    = args.first['val'] || args.first['value']
      currency = args.first['currency']
    end

    return 'Price to be finalised on booking completion' if price.nil?

    return format('%.2f', price) if currency.nil?

    number_to_currency(price, unit: currency, format: '%n %u')
  end

  def valid_price_hash?(args)
    args.size == 1 &&
      args.first.is_a?(Hash)                     &&
      (args.first['val'] || args.first['value']) &&
      args.first['currency']
  end

  def trunc(text)
    truncate(text, length: 50, separator: /\w/, omission: '...')
  end

  def line_wrap(text, col = 40)
    s = text.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n")
    truncate(s, length: 120, separator: /\w/, omission: '...')
  end

  def formatted_datetime(datetime)
    datetime&.strftime('%d %b %Y | %I:%M %p')
  end

  def formatted_date(datetime)
    datetime.strftime('%d %b %Y')
  end
end

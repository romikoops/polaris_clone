module ApplicationHelper
  def asset_data_base64(path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def format_to_price(price, currency = nil)
    if currency.nil?
      ("%.2f" % price)
    else
      number_to_currency(price, unit: currency, format: "%n %u")
    end
  end

  def trunc(text)
    truncate(text, length: 50, separator: /\w/, omission: "...")
  end

  def line_wrap(text, col = 40)
    s = text.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n")
    truncate(s, length: 120, separator: /\w/, omission: "...")
  end

  def formatted_datetime_full(datetime)
    datetime.strftime("%m/%d/%y (%d %b %Y) | %I:%M%p")
  end

  def formatted_datetime(datetime)
    if datetime
      datetime.strftime("%d %b %Y | %I:%M %p")
    end
    
  end
  
  def formatted_date_full(datetime)
    datetime.strftime("%m/%d/%y (%d %b %Y)")
  end

  def formatted_date(datetime)
    datetime.strftime("%d %b %Y")
  end
  def flash_messages
    flash.map do |type, text|
      { id: text.object_id, type: type, text: text }
    end
  end
end
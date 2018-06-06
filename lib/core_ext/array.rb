# frozen_string_literal: true

class Array
  def log_format
    to_s.tr('"', "'")
  end

  def sql_format
    "(#{join(', ')})"
  end
end

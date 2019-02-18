# frozen_string_literal: true

class Array
  def log_format
    to_s.tr('"', "'")
  end

  def sql_format
    "(#{join(', ')})"
  end

  def string_sql_format
    "(#{map{|x| "'#{x}'"}.join(', ')})"
  end

  def each_with_times(arg)
    num_times =
      case arg
      when Float   then arg > rand ? 1 : 0
      when Range   then rand(arg)
      when Integer then arg
      else raise ArgumentError
      end

    each do |elem|
      num_times.times { yield elem }
    end
  end
end

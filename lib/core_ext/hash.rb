# frozen_string_literal: true

class Hash
  def deep_values
    values.map { |value| value.is_a?(Hash) ? value.deep_values : value }.flatten
  end

  def map_deep_values(&block)
    map_values { |value| value.is_a?(Hash) ? value.map_deep_values(&block) : yield(value) }
  end

  def map_deep_values!(&block)
    map_values! { |value| value.is_a?(Hash) ? value.map_deep_values!(&block) : yield(value) }
  end

  def map_values
    each_with_object({}) do |(k, v), return_h|
      return_h[k] = yield(v)
    end
  end

  def map_values!
    each do |k, v|
      self[k] = yield(v)
    end
  end

  def each_deep_key(&block)
    each do |key, value|
      yield(key)
      value.each_deep_key(&block) if value.is_a? Hash
    end
  end

  def deep_each(&block)
    each do |key, value|
      yield(key, value)
      value.each_deep_key(&block) if value.is_a? Hash
    end
  end

  def to_sql_where
    'WHERE ' + map { |k, v| v.is_a?(String) ? "#{k} = '#{v}'" : "#{k} = #{v}" }.join(' AND ')
  end
end

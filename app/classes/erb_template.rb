# frozen_string_literal: true

class ErbTemplate
  include ApplicationHelper
  include ActionView::Helpers
  BASE_PATH = "#{Rails.root}/app/views"

  def initialize(args)
    @template = find_file args[:template]
    @layout   = find_file args[:layout], layout: true

    set_locals args[:locals] if args[:locals].is_a? Hash

    raise ArgumentError, 'Invalid template' if @template.nil?
  end

  def render
    templates = [@template, @layout].reject(&:nil?)
    templates.reduce(nil) do |prev, temp|
      _render(temp) { prev }
    end
  end

  private

  def _render(temp)
    ERB.new(temp).result(binding)
  end

  def set_locals(locals)
    locals.each do |k, v|
      define_singleton_method(k) { v }
    end
  end

  def find_file(arg_path, options = {})
    return nil if arg_path.nil?

    full_path = "#{BASE_PATH}#{'/layouts' if options[:layout]}/#{arg_path}"

    [arg_path, full_path].each do |path|
      return File.read(path) if File.exist? path
    end

    nil
  end
end

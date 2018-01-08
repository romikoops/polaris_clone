class BasicErb
  include WickedPdfHelper
  include ApplicationHelper
  include ActionView::Helpers
  
  def initialize(args)
    @template = File.read(args[:template]) if args[:template]
    @layout   = File.read(args[:layout])   if args[:layout]
    @locals   = args[:locals]
    @locals.each do |k, v|
      self.define_singleton_method(k) { v }
    end
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
end
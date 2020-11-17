# frozen_string_literal: true

class EngineGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('template', __dir__)

  desc 'This generators creates new CBRA engines'
  class_option :type, aliases: ['-t'], type: :string, required: true,
                      desc: 'Engine type (options: api/service/data)'

  def create_engine
    @engine_name = name.downcase
    @namespace = name.camelize
    @engine_type = options['type']

    raise 'Invalid Engine Name' unless @engine_name[/\A[a-z_]+\z/]
    raise 'Invalid Engine Type' unless %w[api service data].include?(@engine_type)

    # Create engine template
    template_dir = Rails.root.join('tmp', Time.now.to_i.to_s)
    template_engine = template_dir.join('engine')

    # Copy our template as new engine
    directory 'engine', template_engine, verbose: false

    # Rename required files
    inside template_engine do
      unless @engine_type == 'view'
        remove_dir 'app/controllers', verbose: false
        remove_dir 'config', verbose: false
      end

      remove_dir 'app/models', verbose: false unless @engine_type == 'data'
      remove_dir 'app/services', verbose: false unless @engine_type == 'service'

      Dir['**/*engine_template*'].each do |item|
        new_item = item.gsub(/engine_template/, @engine_name)
        run "mv #{Shellwords.escape(item)} #{Shellwords.escape(new_item)}", verbose: false
      end
    end

    # Create our engine
    source_paths.unshift(template_dir)
    directory "engine", "engines/#{@engine_name}"
    inside "engines/#{@engine_name}" do
      Dir['bin/*'].each { |bin| chmod bin, 0o0755, verbose: false }
    end

    in_root do
      create_link "engines/#{@engine_name}/spec/internal/config/database.yml", "../../../../../config/database.yml"
    end
  ensure
    remove_dir template_dir, verbose: false
  end
end

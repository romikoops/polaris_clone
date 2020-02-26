# frozen_string_literal: true

class EngineGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('template', __dir__)

  desc 'This generators creates new CBRA engines'
  class_option :type, aliases: ['-t'], type: :string, required: true,
                      desc: 'Engine type (options: view/service/data)'

  def create_engine # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
    @engine_name = name.downcase
    @engine_type = options['type']
    @engine_dest = "engines/#{@engine_name}"

    raise 'Invalid Engine Name' unless @engine_name[/\A[a-z_]+\z/]
    raise 'Invalid Engine Type' unless %w[view service data].include?(@engine_type)

    # Create engine template
    template_dir = Rails.root.join('tmp', Time.now.to_i.to_s)
    template_engine = template_dir.join('engine')

    # Copy our template as new engine
    directory 'engine', template_engine, verbose: false

    # Rename required files
    inside template_engine do
      Dir['**/*'].each do |item|
        next unless File.file?(item)

        gsub_file item, /(engine_template|EngineTemplate|engine_type|GITUSER_NAME|GITUSER_EMAIL)/, verbose: false do |m|
          case m
          when 'engine_template' then @engine_name
          when 'EngineTemplate'  then @engine_name.camelize
          when 'engine_type'     then @engine_type
          when 'GITUSER_NAME'    then `git config user.name`.strip
          when 'GITUSER_EMAIL'   then `git config user.email`.strip
          end
        end
      end

      unless @engine_type == 'view'
        remove_dir 'app/controllers', verbose: false
        remove_dir 'config', verbose: false
        remove_file 'spec/dummy/config/routes.rb', verbose: false
      end

      remove_dir 'app/models', verbose: false
      remove_dir 'app/services', verbose: false unless @engine_type == 'service'

      Dir['**/*engine_template*'].each do |item|
        new_item = item.gsub(/engine_template/, @engine_name)
        run "mv #{Shellwords.escape(item)} #{Shellwords.escape(new_item)}", verbose: false
      end
    end

    source_paths.unshift(template_dir)

    directory 'engine', @engine_dest
    inside @engine_dest do
      Dir['bin/*'].each { |bin| chmod bin, 0o0755, verbose: false }
    end
  ensure
    remove_dir template_dir, verbose: false
  end
end

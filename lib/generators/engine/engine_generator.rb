# frozen_string_literal: true

class EngineGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('template', __dir__)

  def create_engine # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
    engine_name = name.downcase

    # Define engine destination
    engine = "engines/#{engine_name}"

    raise 'Invalid Engine Name' unless engine_name[/\A[a-zA-Z_]+\z/]

    # Create engine template
    template_dir = Rails.root.join('tmp', '._template')
    template_engine = template_dir.join('engine')

    # Copy our template as new engine
    directory 'engine', template_engine, verbose: false

    # Rename required files
    inside template_engine do
      Dir['**/*'].each do |item|
        next unless File.file?(item)

        gsub_file item, /(engine_template|EngineTemplate|GITUSER_NAME|GITUSER_EMAIL)/, verbose: false do |m|
          case m
          when 'engine_template' then engine_name
          when 'EngineTemplate'  then engine_name.camelize
          when 'GITUSER_NAME'    then `git config user.name`.strip
          when 'GITUSER_EMAIL'   then `git config user.email`.strip
          end
        end
      end

      Dir['**/*engine_template*'].each do |item|
        run "mv #{Shellwords.escape(item)} #{Shellwords.escape(item.gsub(/engine_template/, engine_name))}", verbose: false
      end

      Dir['bin/*'].each { |bin| chmod bin, 0o0755, verbose: false }
    end

    source_paths.unshift(template_dir)

    directory 'engine', engine
    inside engine do
      Dir['bin/*'].each { |bin| chmod bin, 0o0755, verbose: false }
    end
  ensure
    remove_dir template_dir, verbose: false
  end
end

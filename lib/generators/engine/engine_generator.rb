# frozen_string_literal: true

class EngineGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('template', __dir__)

  def create_engine # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize
    # Define engine destination
    engine = "engines/#{name}"

    raise 'Invalid Engine Name' unless name[/\A[a-zA-Z_]+\z/]

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
          when 'engine_template' then name
          when 'EngineTemplate'  then name.camelize
          when 'GITUSER_NAME'    then `git config user.name`.strip
          when 'GITUSER_EMAIL'   then `git config user.email`.strip
          end
        end
      end

      Dir['**/*engine_template*'].each do |item|
        run "mv #{Shellwords.escape(item)} #{Shellwords.escape(item.gsub(/engine_template/, name))}", verbose: false
      end

      Dir['bin/*'].each { |bin| chmod bin, 0o0755, verbose: false }
    end

    source_paths.unshift(template_dir)
    directory 'engine', engine
  ensure
    remove_dir template_dir, verbose: false
  end
end

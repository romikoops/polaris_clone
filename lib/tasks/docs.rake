# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  namespace :docs do
    desc 'Generate API request documentation from API specs'
    task :api => 'api:clean' do
      # Ensure documentation directory exists
      docs_path = Rails.root.join('doc/api')
      FileUtils.mkdir_p docs_path unless File.directory?(docs_path)
      unless File.file?(docs_path.join('index.json'))
        File.open(docs_path.join('index.json'), 'w') { |f| f.write JSON.dump({}) }
      end

      Dir['engines/*'].each do |engine|
        next unless File.directory?(File.join(engine, 'spec/acceptance'))

        puts "==> Generating docs for #{File.basename(engine)}"

        Dir.chdir(engine) do
          Bundler.with_clean_env do
            sh('bundle exec rspec spec/acceptance --format RspecApiDocumentation::ApiFormatter --order defined')
          end
        end

        Dir[File.join(engine, 'doc/api/*/*.json')].each do |json|
          next unless File.file?(json)

          dir = File.dirname(Rails.root.join(json.gsub("#{engine}/", '')))
          FileUtils.mkdir_p dir unless File.directory?(dir)
          FileUtils.cp json, dir
        end
      end
    end

    namespace :api do
      desc 'Cleans generated API documentation'
      task :clean do
        puts 'Cleaning API Docs directory'
        FileUtils.rm_rf Rails.root.join('doc/api')
      end
    end
  end
end

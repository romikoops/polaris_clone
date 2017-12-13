source 'https://rubygems.org'
ruby "2.4.2"
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.7'
gem 'devise_token_auth'
gem 'omniauth'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Use geocoder for backend geocoding
gem 'geocoder'

# Use Nokogiri for XML-parsing
gem 'nokogiri'

# Use Wicked PDF to generate PDFs from HTML
# The obligatory wkhtmltopdf binaries are here: [Rails.root]/bin/wkhtmltopdf
gem 'wicked_pdf'
gem 'mongo', '~> 2.4'
# Use roo for handling CSV and Excel files
gem 'roo'
gem 'http'
gem 'chronic'
# Use table_print for nice SQL output
gem 'table_print'

# Filter and sort Active record collections
gem "filterrific"
# Pagination library
gem 'will_paginate', '~> 3.1.5'

# Easier CSS for emails
gem 'premailer-rails'
gem 'inky-rb', require: 'inky'
gem "mini_magick"
# AWS SDK for hosting and S3
gem 'aws-sdk', '~> 3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

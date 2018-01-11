Rails.application.config.assets.precompile += %w( foundation_emails.css pdfs.scss.erb )

Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.precompile += %w(.svg .eot .woff .ttf .otf)
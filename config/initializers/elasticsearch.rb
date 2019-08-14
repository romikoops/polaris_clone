# frozen_string_literal: true

ENV['ELASTICSEARCH_URL'] = Settings.elasticsearch.url
Searchkick.index_suffix = ENV['REVIEW_APP_NAME']

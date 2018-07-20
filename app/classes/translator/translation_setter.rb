# frozen_string_literal: true
include AwsConfig
extend AwsConfig
module Translator
  class TranslationSetter < Translator::BaseTranslator
    attr_reader :text, :key, :lang, :section

    
    def post_initialize(args)
      @text = args[:text]
      @lang = args[:lang]
      @section = args[:section] || "common"
      @key = args[:key] || SecureRandom.uuid
      @bucket = 'assets.itsmycargo.com'
      @aws = AwsConfig::ClassMethods.aws_client
      @base_url = "https://translations.itsmycargo.com/"
      
      @s3_path = "translations/#{@lang}/#{@section}.json"
      @invalidation_key = "/#{@lang}/#{@section}.json"
      @tmp_path = "#{Rails.root.join('tmp','locales',@lang, @section)}.json"
      
    end

    def perform
      perform_set_translation
    end

    def fetch_data
      obj = @aws.get_object({
        key: @s3_path,
        bucket: @bucket
      })
      json_string = obj.body.read
      # json_string = File.read(@tmp_path)
      @json_data = JSON.parse(json_string).to_h
      awesome_print @json_data
    end
    def invalidate_translation_host()
      cloudfront = Aws::CloudFront::Client.new(
        access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        region:            ENV["AWS_REGION"]
      )
      invalArray = [@invalidation_key]
      invalStr = Time.now.to_i.to_s + "_subdomain"
      resp = cloudfront.create_invalidation(
        distribution_id: 'ETIBQ5CHMRN4T', # required
        invalidation_batch: { # required
          paths:            { # required
            quantity: invalArray.length, # required
            items:    invalArray
          },
          caller_reference: invalStr.to_s, # required
        }
      )
    end

    protected

    def perform_set_translation
      fetch_data
      @json_data[key.to_s] = @text
      
      File.open(@tmp_path, 'w') do |f|
        f.write(@json_data.to_json)
      end
      file = open(@tmp_path)
      
      @aws.put_object(bucket: @bucket, key: @s3_path, body: file, content_type: 'application/json', acl: 'public-read')
      puts "#{@key} #{@text}"
      # invalidate_translation_host
      return @key
    end

  end
end

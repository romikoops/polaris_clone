class SuperAdminsController < ApplicationController
  before_action :require_login_and_role_is_super_admin
  include MultiTenantTools
  include Response
  def new_demo_site
    if params[:file]
      tenant = JSON.parse(File.read(params[:file].tempfile))
      new_site(tenant, true)
      response_handler(true)
    else
      response_handler(false)
    end
  end
  def upload_image
    file = params[:file]
    s3 = Aws::S3::Client.new(
        access_key_id: ENV['AWS_KEY'],
        secret_access_key: ENV['AWS_SECRET'],
        region: "eu-central-1"
      )
     objKey = 'images/demo_images/' + file.original_filename
    awsurl = "https://assets.itsmycargo.com/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: file.content_type, acl: 'public-read')
    response_handler({url: awsurl})
  end
  private

  def require_login_and_role_is_super_admin
    unless user_signed_in? && current_user.role.name == "super_admin"
      response_handler(false)
    end
  end
end

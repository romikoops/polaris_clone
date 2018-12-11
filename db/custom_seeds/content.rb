default_content = {
  "text": "",
  "component": "",
  "section": "",
  "index": 0
}
custom_content = {
  "normanglobal": [
    {
      "text": '<h2 ><b>Norman Global Online</b></h2>',
      "component": "LandingTop",
      "section": "welcome",
      "index": 0
    },
    {
      "text": '<h2 ><i>Quote. Book. Confirm.</i></h2>',
      "component": "LandingTop",
      "section": "welcome",
      "index": 1
    },
    {
      "text": '<h3 >Get real-time quotes and create automatic bookings, with our easy to quote & booking system.</h3>',
      "component": "LandingTop",
      "section": "welcome",
      "index": 2
    },
    {
      "text": '<h3 ><i> -Trust us to deliver for you every time.</i></h3>',
      "component": "LandingTop",
      "section": "welcome",
      "index": 3
    },
    {
      "text": '<p >Enter your shipping requirements and let us compute your real-time quote!</p>',
      "component": "Landing",
      "section": "services",
      "index": 0
    },
    {
      "text": '<p >Get full visibility on your freight cost with a full breakdown with no hidden costs</p>',
      "component": "Landing",
      "section": "services",
      "index": 1
    },
    {
      "text": '<p >Like what you see? Confirm your selected service and hit Book</p>',
      "component": "Landing",
      "section": "services",
      "index": 2
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Place bookings from China to UK without hassle </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 0
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">See your quoted or pre-negotiated rates for all modes of transport we offer on each route </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 1
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Get an instant overview of the available freight options </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 2
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">See full costs relating to your shipment selection with no hidden fees  </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 3
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Repeat shipments and store addresses for next time  </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 4
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">View or download shipping history and documents as you need them  </p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 5
    },
    {
      "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Pull data and reports on your logistics</p></div>',
      "component": "Landing",
      "section": "bullets",
      "index": 6
    },
    {
      "text": '<p class="flex">Thanks for registering an account with <b>Norman Global Online</b>. We are really thrilled to have you on board and trust you will enjoy our seamless Online quote and booking system. </p>',
      "component": "WelcomeMail",
      "section": "body",
      "index": 0
    },
    {
      "text": '<p class="flex">We look forward to supporting you and your business. </p>',
      "component": "WelcomeMail",
      "section": "body",
      "index": 1,
      "image": 'assets/images/ngl_welcome_image.jpg'
    },
    {
      "text": '<p class="flex">Thanks for Trusting us to deliver. <br/><br/>Best Regards <br/>Norman Global Logistics <br/><br/><br/>You are receiving this email because you opted in and requested a user account.</p>',
      "component": "WelcomeMail",
      "section": "body",
      "index": 2
    },
    {
      "text": '<mj-social font-size="15px" icon-size="30px" mode="horizontal">
          <mj-social-element name="linkedin-noshare" href="https://www.linkedin.com/company/norman-global-logistics-hong-kong-limited/">
            LinkedIn
          </mj-social-element>
          <mj-social-element  name="twitter-noshare" href="https://twitter.com/normanglobal">
            Twitter
          </mj-social-element>
        </mj-social>',
      "component": "WelcomeMail",
      "section": "social",
      "index": 0
    },
    {
      "text": '<p class="flex">Norman Global Logistics Hong Kong Limited | Tower 1, 8/F, Unit 811 | Cheung Sha Wan Plaza | 833 Cheung Sha Wan Rd | Kowloon | Hong Kong S.A.R | <br/>
      LONDON | SHANGHAI | HONG KONG | QINGDAO | NINGBO | FELIXSTOWE | LIVERPOOL | MANCHESTER | NORTHAMPTON | HO CHI MINH <br/><br/>
      All transactions are subject to the Companys Standard Trading Conditions (copy is available upon request), which in certain circumstances limit or exempt the Companys liability. Whilst this message has been checked for virus the recipient should verify this email and any attachments for the presence of viruses as the company accepts no liability for any damage caused by any virus transmitted by this email. <br/>
      本公司所有業務均根據本公司之標準營運條款進行。在某些情況下，該條款將免除或限制本公司之責任。條款之副本可從本公司索取。  
      </p>',
      "component": "WelcomeMail",
      "section": "footer",
      "index": 0
    },
    {
      "text": 'Welcome to Norman Global Logistics!',
      "component": "WelcomeMail",
      "section": "subject",
      "index": 0
    }
  ]
}
s3 = Aws::S3::Client.new(
  # access_key_id: Settings.aws.access_key_id,
  # secret_access_key: Settings.aws.secret_access_key,
  # region: Settings.aws.region
)
custom_content.each do |subdomain, content_array|
  tenant = Tenant.find_by_subdomain(subdomain)
  content_array.each do |content_hash|
    content = Content.find_or_create_by!(
      tenant_id: tenant.id, 
      component: content_hash[:component], 
      section: content_hash[:section], 
      index: content_hash[:index]
    )
    content.text = content_hash[:text]
    if content_hash[:image]
      file = s3.get_object(bucket: 'assets.itsmycargo.com', key: content_hash[:image]).body
      file_name = content_hash[:image].split('/').last
      content.image.attach(io: file, filename: file_name)
    end
    content.save!
  end
end


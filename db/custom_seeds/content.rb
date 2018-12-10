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
    }
  ]
}
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
    content.save!
  end
end


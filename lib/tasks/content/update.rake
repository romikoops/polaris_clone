# frozen_string_literal: true
namespace :content do
  task update: :environment do
    custom_content = {
      "normanglobal": [
        {
          "text": '<img src="https://assets.itsmycargo.com/assets/tenants/normanglobal/normanglobal_logo_white.png" alt="" class="flex-none landing_logo_large"/>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 0
        },
        {
          "text": '<h1 class="ngl_title">Norman Global Logistics Online</h1>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 1
        },
        {
          "text": '<h2 ><i>Quote. Book. Confirm.</i></h2>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 2
        },
        {
          "text": '<h3 >Get real-time quotes and create automatic bookings, with our easy to quote & booking system.</h3>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 3
        },
        {
          "text": '<h3 ><i> -Trust us to deliver for you every time.</i></h3>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 4
        },
        {
          "text": '<h2 class="flex-none">Get real-time quotes and create automatic bookings, with our new easy to quote & booking system. </h2>',
          "component": 'Landing',
          "section": 'serviceTitles',
          "index": 0
        },
        {
          "text": '<h4 class="flex-none">Why use Norman Global Online?</h4>',
          "component": 'Landing',
          "section": 'serviceTitles',
          "index": 1
        },
        {
          "text": '<p >Enter your shipping requirements and let us compute your real-time quote!</p>',
          "component": 'Landing',
          "section": 'services',
          "index": 0
        },
        {
          "text": '<p >Get full visibility on your freight cost with a full breakdown with no hidden costs</p>',
          "component": 'Landing',
          "section": 'services',
          "index": 1
        },
        {
          "text": '<p >Like what you see? Confirm your selected service and hit Book</p>',
          "component": 'Landing',
          "section": 'services',
          "index": 2
        },
        {
          "text": '<h2 class="flex-none">The core benefits of managing your logistics online with Norman Global Online</h2>',
          "component": 'Landing',
          "section": 'bulletTitles',
          "index": 0
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Place bookings from China to UK without hassle </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 0
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">See your quoted or pre-negotiated rates for all modes of transport we offer on each route </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 1
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Get an instant overview of the available freight options </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 2
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">See full costs relating to your shipment selection with no hidden fees  </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 3
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Repeat shipments and store addresses for next time  </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 4
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">View or download shipping history and documents as you need them  </p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 5
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Pull data and reports on your logistics</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 6
        },
        {
          "text": '<p class="flex">Thanks for registering an account with <b>Norman Global Online</b>. We are really thrilled to have you on board and trust you will enjoy our seamless Online quote and booking system. </p>',
          "component": 'WelcomeMail',
          "section": 'body',
          "index": 0
        },
        {
          "text": '<p class="flex">We look forward to supporting you and your business. </p>',
          "component": 'WelcomeMail',
          "section": 'body',
          "index": 1,
          "image": "assets/images/ngl_welcome_image.jpg"
        },
        {
          "text": '<p class="flex">Thanks for Trusting us to deliver. <br/><br/>Best Regards <br/>Norman Global Logistics <br/><br/><br/>You are receiving this email because you opted in and requested a user account.</p>',
          "component": 'WelcomeMail',
          "section": 'body',
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
          "component": 'WelcomeMail',
          "section": 'social',
          "index": 0
        },
        {
          "text": '<p class="flex">Norman Global Logistics Hong Kong Limited | Tower 1, 8/F, Unit 811 | Cheung Sha Wan Plaza | 833 Cheung Sha Wan Rd | Kowloon | Hong Kong S.A.R | <br/>
          LONDON | SHANGHAI | HONG KONG | QINGDAO | NINGBO | FELIXSTOWE | LIVERPOOL | MANCHESTER | NORTHAMPTON | HO CHI MINH <br/><br/>
          All transactions are subject to the Companys Standard Trading Conditions (copy is available upon request), which in certain circumstances limit or exempt the Companys liability. Whilst this message has been checked for virus the recipient should verify this email and any attachments for the presence of viruses as the company accepts no liability for any damage caused by any virus transmitted by this email. <br/>
          本公司所有業務均根據本公司之標準營運條款進行。在某些情況下，該條款將免除或限制本公司之責任。條款之副本可從本公司索取。
          </p>',
          "component": 'WelcomeMail',
          "section": 'footer',
          "index": 0
        },
        {
          "text": 'Welcome to Norman Global Logistics!',
          "component": 'WelcomeMail',
          "section": 'subject',
          "index": 0
        }
      ],
      "gateway": [
        {
          "text": '<p>Gateway Cargo Systems GmbH handelt bei Seetransporten einschließlich Vorlauf- und Nachlauftransporten ausschließlich als Agent von G.C.S. Container Line Ltd., Limassol/Zypern. G.C.S. Container Line Ltd. arbeitet ausschließlich nach ihren jeweils gültigen Konnossements-Bedingungen, auch wenn kein Konnossement ausgestellt wurde. Diese Bedingungen können bei den jeweiligen Büros und/oder auf der Webseite <a href="http://www.gatewaycargo.de/downloads.html">http://www.gatewaycargo.de/downloads.html</a> eingesehen werden.</p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 0
        },
        {
          "text": '<p>Bei speditionellen Leistungen, die Gateway Cargo Systems GmbH im eigenen Namen durchführt, gelten ausschließlich die Allgemeinen Deutschen Spediteurbedingungen 2017 – ADSp 2017 –. Hinweis: Die ADSp 2017 weichen in Ziffer 23 hinsichtlich des Haftungshöchstbetrages für Güterschäden (§ 431 HGB) vom </p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 1
        },
        {
          "text": '<p>Gesetz ab, indem sie die Haftung bei multimodalen Transporten unter Einschluss einer Seebeförderung und bei unbekanntem Schadenort auf 2 SZR/kg und im Übrigen die Regelhaftung von 8,33 SZR/kg zusätzlich auf 1,25 Millionen Euro je Schadenfall sowie 2,5 Millionen Euro je Schadenereignis, mindestens aber 2 SZR/kg, beschränken. <a href="http://www.gatewaycargo.de/downloads.html">ADSp</a></p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 2
        },
        {
          "text": '<p>See/Luftfrachten: Lieferfristen können grundsätzlich nicht garantiert werden. Termine basieren auf den Angaben von Reedereien oder Luftfrachtgesellschaften. Insbesondere im Falle von Ereignissen während der Transportdurchführung die für uns unabsehbar, nicht beeinflussbar oder durch uns nicht zu vertreten sind, übernehmen wir keine Haftung</p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 3
        },
        {
          "text": '<p>See/Luftfrachten: Lieferfristen können grundsätzlich nicht garantiert werden. Termine basieren auf den Angaben von Reedereien oder Luftfrachtgesellschaften. Insbesondere im Falle von Ereignissen während der Transportdurchführung die für uns unabsehbar, nicht beeinflussbar oder durch uns nicht zu vertreten sind, übernehmen wir keine Haftung</p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 4
        },
        {
          "text": '<p>Gateway Cargo Systems GmbH is acting for sea transports including pre- and on-carriage exclusively as agent of G.C.S. Container Line Ltd., Limassol/Cyprus. G.C.S. Container Line Ltd. is exclusively working under the conditions of the relevant Bill of Lading, which can be viewed at one of the offices and/or the website: <a href="http://www.gatewaycargo.de/downloads.html"> http://www.gatewaycargo.de/downloads.html</a></p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 5
        },
        {
          "text": '<p>For forwarding services in the name of Gateway Cargo Systems GmbH exclusively the Allgemeinen Deutschen Spediteurbedingungen 2017 – ADSp 2017 – (German Freight Forwarders General Terms and Conditions 2017) are valid. Note: In clause 23 the ADSp 2017 deviates from the statutory liability limitation in section 431 German Commercial Code (HGB) by limiting the liability for multimodal transportation with the involvement of sea carriage and an unknown damage location to 2 SDR/kg and, for the rest, the customary liability limitation of 8,33 SDR/kg additionally to Euro 1,25 million per damage claim and EUR 2,5 million per damage event, but not less than 2 SDR/kg. <a href="http://www.gatewaycargo.de/downloads.html">ADSp</a></p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 6
        },
        {
          "text": '<p>Sea/Airfreight: Delivery dates can’t be guaranteed in principal. Dates based on the data of the shipping lines or airlines. Especially in case of events during the transport, that are incalculable, not influenceable for us or we are not responsible, we take no liability.</p>',
          "component": 'QuotePdf',
          "section": 'disclaimer',
          "index": 7
        }
      ],
      "unsworth": [
        {
          "text": '<img class="tenant_logo_landing flex-none" src="https://assets.itsmycargo.com/assets/tenants/unsworth/cargocostlight.png" alt="" class="flex-none landing_logo_large"/>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 0
        },
        {
          "text": '<h2 class="bold">Real time global freight rates in seconds.</h2>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 1
        },
        {
          "text": '<div className="wrapper_hr"><hr /></div>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 2
        },
        {
          "text": '<div class="wrapper_h3"><h3 >Finally, shipping in and out of the UK is as simple as it should be.</h3></div>',
          "component": 'LandingTop',
          "section": 'welcome',
          "index": 3
        },
        {
          "text": '<h3 class="flex-none">Cargocost.com is powered by Unsworth. A family owned freight forwarder, established in 1974</h3>',
          "component": 'Landing',
          "section": 'serviceTitles',
          "index": 0
        },
        {
          "text": '<h3 class="flex-none">We leverage a global network to operate our award winning LCL consolidation services, with regular and reliable departures into and out of the UK.</h3>',
          "component": 'Landing',
          "section": 'bulletTitles',
          "index": 0
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Quote and book online for any of our core services</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 0
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Award winning customer care and operational excellence</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 1
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Unlock loyalty pricing for repeat shipments</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 2
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Best-in-class visibility with Pathway and One-Click Track</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 3
        },
        {
          "text": '<div class="flex layout-row layout-align-start-center"><i class="flex-none fa fa-check"></i><p class="flex">Monthly reporting and KPI dashboards</p></div>',
          "component": 'Landing',
          "section": 'bullets',
          "index": 4
        },
        {
          # "text": '<div className="flex btm_promo_img_tag"><img src="https://assets.itsmycargo.com/assets/tenants/unsworth/cargocost_services.png"/></div>',
          "image": "assets/tenants/unsworth/cargocost_services.png",
          "component": 'Landing',
          "section": 'bulletImage',
          "index": 4
        }
      ]
    }
    s3 = Aws::S3::Client.new

    custom_content.each do |subdomain, content_array|
      tenant = ::Tenant.find_by_subdomain(subdomain)
      ::Content.where(tenant_id: tenant.id).destroy_all
      content_array.each do |content_hash|
        content = ::Content.find_or_create_by!(
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
  end
end

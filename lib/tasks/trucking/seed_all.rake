# frozen_string_literal: true

namespace :trucking do
  task :seed_all, [] => :environment do
    targets = {
      # normanglobal: [
        # {
        #   hub: 'Shanghai Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__shanghai_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__shanghai_port.xlsx']
        # },
        # {
        #   hub: 'Dalian Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__dalian_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__dalian_port.xlsx']
        # },
        # {
        #   hub: 'Tianjin Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__tianjin_xingang_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__tianjin_xingang_port.xlsx']
        # },
        # {
        #   hub: 'Xingang Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__tianjin_xingang_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__tianjin_xingang_port.xlsx']
        # },
        # {
        #   hub: 'Qingdao Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__qingdao_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__qingdao_port.xlsx']
        # },
        # {
        #   hub: 'Hong Kong Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__hong_kong_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__hong_kong_port.xlsx']
        # },
        # {
        #   hub: 'Shenzhen Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__shenzhen_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__shenzhen_port.xlsx']
        # },
        # {
        #   hub: 'Xiamen Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__xiamen_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__xiamen_port.xlsx']
        # },
        # {
        #   hub: 'Gothenburg Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__gothenburg_port.xlsx',
        #           'data/normanglobal/normanglobal__trucking_ltl__gothenburg_port.xlsx']
        # },
        # {
        #   hub: 'Southampton Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__southampton_port.xlsx',
        #         'data/normanglobal/normanglobal__trucking_ltl__southampton_port.xlsx']
        # },
        # {
        #   hub: 'Felixstowe Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ftl__felixstowe_port.xlsx',
        #         'data/normanglobal/normanglobal__trucking_ltl__felixstowe_port.xlsx']
        # },
        # {
        #   hub: 'Ningbo Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ltl__ningbo_port.xlsx']
        # },
        # {
        #   hub: 'Fuzhou Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ltl__fuzhou_port.xlsx']
        # },
        # {
        #   hub: 'Foshan Port',
        #   urls: ['data/normanglobal/normanglobal__trucking_ltl__foshan_port.xlsx']
        # },
        # {
        #   hub: "Zhuhai Port",
        #   urls: ['data/normanglobal/normanglobal__trucking_ltl__zhuhai_port.xlsx']
        # },
      #   {
      #     hub: 'Zhongshan Port',
      #     urls: ['data/normanglobal/normanglobal__trucking_ltl__zhongshan_port.xlsx']
      #   },
      #   {
      #     hub: 'Stockholm Port',
      #     urls: ['data/normanglobal/normanglobal__trucking_ftl__stockholm_port.xlsx']
      #   },
      #   {
      #     hub: 'Helsingborg Port',
      #     urls: ['data/normanglobal/normanglobal__trucking_ftl__helsingborg_port.xlsx']
      #   }
      # ],
      # greencarrier: [
      #   {
      #     hub: 'Gothenburg Port',
      #     urls: [
      #       'data/greencarrier/greencarrier__trucking_ftl__gothenburg_port.xlsx',
      #       'data/greencarrier/greencarrier__trucking_ltl__gothenburg_port.xlsx'
      #     ]
      #   },
      #   {
      #     hub: 'Shanghai Port',
      #     urls: [
      #       'data/greencarrier/greencarrier__trucking_ftl__shanghai_port.xlsx',
      #       'data/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx'
      #     ]
      #   },
      #   {
      #     hub: 'Ipswich Port',
      #     urls: ['data/greencarrier/greencarrier__trucking_ftl__ipswich_port.xlsx']
      #   },
      #   {
      #     hub: 'Gothenburg Airport',
      #     urls: ['data/greencarrier/greencarrier__trucking_ltl__gothenburg_airport.xlsx']
      #   },
      #   {
      #     hub: 'Stockholm Airport',
      #     urls: ['data/greencarrier/greencarrier__trucking_ltl__stockholm_airport.xlsx']
      #   },
      #   {
      #     hub: 'Malmo Airport',
      #     urls: ['data/greencarrier/greencarrier__trucking_ltl__malmo_airport.xlsx']
      #   }
      # ],
      # fivestar: [
      #   {
      #     hub: 'Hamburg Port',
      #     urls: ['data/fivestar/fivestar__trucking_ltl__hamburg_port.xlsx']
      #   }
      # ],
      # gateway: [
      #   {
      #     hub: 'Hamburg Port',
      #     urls: ['data/gateway/gateway__trucking_ltl__hamburg_port.xlsx']
      #   }
      # ],
      # speedtrans: [
      #   {
      #     hub: 'Hamburg Port',
      #     urls: ['data/speedtrans/speedtrans__trucking_ltl__hamburg_port.xlsx']
      #   }
      # ],
      # berkman: [
      #   {
      #     hub: 'Rotterdam Port',
      #     urls: ['data/berkman/berkman__trucking_ltl__rotterdam_port.xlsx']
      #   }
      # ],
      schryver: [
        {
          hub: 'Hamburg Port',
          urls: ['data/schryver/schryver__trucking_ftl__hamburg_port.xlsx']
        }
      ],
      demo: [
        # {
        #   hub: 'Gothenburg Port',
        #   urls: [
        #     'data/greencarrier/greencarrier__trucking_ftl__gothenburg_port.xlsx',
        #     'data/greencarrier/greencarrier__trucking_ltl__gothenburg_port.xlsx'
        #   ]
        # },
        # {
        #   hub: 'Shanghai Port',
        #   urls: [
        #     'data/greencarrier/greencarrier__trucking_ftl__shanghai_port.xlsx',
        #     'data/greencarrier/greencarrier__trucking_ltl__shanghai_port.xlsx'
        #   ]
        # },
        # {
        #   hub: 'Ipswich Port',
        #   urls: ['data/greencarrier/greencarrier__trucking_ftl__ipswich_port.xlsx']
        # },
        # {
        #   hub: 'Gothenburg Airport',
        #   urls: ['data/greencarrier/greencarrier__trucking_ltl__gothenburg_airport.xlsx']
        # },
        # {
        #   hub: 'Stockholm Airport',
        #   urls: ['data/greencarrier/greencarrier__trucking_ltl__stockholm_airport.xlsx']
        # },
        # {
        #   hub: 'Malmo Airport',
        #   urls: ['data/greencarrier/greencarrier__trucking_ltl__malmo_airport.xlsx']
        # },
        {
          hub: 'Hamburg Port',
          urls: ['data/speedtrans/speedtrans__trucking_ltl__hamburg_port.xlsx']
        }
      ]
    }

    targets.each do |subdomain, values|
      tenant = Tenant.find_by(subdomain: subdomain)
      values.each do |hub_and_urls|
        hub = tenant.hubs.find_by_name(hub_and_urls[:hub])
        hub_and_urls[:urls].each do |url|
          file_url = Aws::S3::Presigner.new(
            access_key_id: Settings.aws.access_key_id,
            secret_access_key: Settings.aws.secret_access_key,
            region: Settings.aws.region
          ).presigned_url(
            :get_object,
            bucket: 'assets.itsmycargo.com',
            key: url,
            response_content_disposition: 'attachment'
          )

          req = { 'xlsx' => file_url }
          Trucking::Excel::Inserter.new(params: req, hub_id: hub.id).perform
        end
      end
    end
  end
end
# old_tp_ids = Rate.joins(truckings: :location).where('trucking_truckings.hub_id': hub.id).where('trucking_locations.id': td_ids).where(scope: @trucking_rate_scope).distinct.ids
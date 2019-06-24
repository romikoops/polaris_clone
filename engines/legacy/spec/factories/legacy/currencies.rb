# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_currency, class: 'Legacy::Currency' do # rubocop:disable Metrics/BlockLength
    today do # rubocop:disable Metrics/BlockLength
      { 'AED' => 4.115659,
        'AFN' => 85.434479,
        'ALL' => 125.435218,
        'AMD' => 545.067579,
        'ANG' => 2.06707,
        'AOA' => 355.884913,
        'ARS' => 47.861343,
        'AUD' => 1.587237,
        'AWG' => 2.017938,
        'AZN' => 1.910326,
        'BAM' => 1.956648,
        'BBD' => 2.231665,
        'BDT' => 94.382586,
        'BGN' => 1.955869,
        'BHD' => 0.4224,
        'BIF' => 2056.033927,
        'BMD' => 1.120454,
        'BND' => 1.513507,
        'BOB' => 7.742732,
        'BRL' => 4.318123,
        'BSD' => 1.120623,
        'BTC' => 0.000229,
        'BTN' => 77.224991,
        'BWP' => 11.932577,
        'BYN' => 2.401638,
        'BYR' => 21_960.907344,
        'BZD' => 2.258668,
        'CAD' => 1.495011,
        'CDF' => 1833.06343,
        'CHF' => 1.118326,
        'CLF' => 0.028065,
        'CLP' => 754.514629,
        'CNY' => 7.533266,
        'COP' => 3519.795629,
        'CRC' => 670.188339,
        'CUC' => 1.120454,
        'CUP' => 29.692043,
        'CVE' => 110.664487,
        'CZK' => 25.738179,
        'DJF' => 199.126822,
        'DKK' => 7.465254,
        'DOP' => 56.779075,
        'DZD' => 133.922372,
        'EGP' => 19.40459,
        'ERN' => 16.807253,
        'ETB' => 32.241116,
        'EUR' => 1,
        'FJD' => 2.388586,
        'FKP' => 0.857955,
        'GBP' => 0.853125,
        'GEL' => 3.013838,
        'GGP' => 0.853355,
        'GHS' => 6.016713,
        'GIP' => 0.857954,
        'GMD' => 55.636177,
        'GNF' => 10_336.192519,
        'GTQ' => 8.605762,
        'GYD' => 234.505506,
        'HKD' => 8.796744,
        'HNL' => 27.535138,
        'HRK' => 7.428837,
        'HTG' => 94.082263,
        'HUF' => 321.342623,
        'IDR' => 15_932.862369,
        'ILS' => 4.060302,
        'IMP' => 0.853355,
        'INR' => 77.222055,
        'IQD' => 1333.340803,
        'IRR' => 47_176.734317,
        'ISK' => 136.112959,
        'JEP' => 0.853355,
        'JMD' => 140.572357,
        'JOD' => 0.79442,
        'JPY' => 124.735154,
        'KES' => 112.943119,
        'KGS' => 78.26412,
        'KHR' => 4504.226747,
        'KMF' => 492.495607,
        'KPW' => 1008.467134,
        'KRW' => 1274.393796,
        'KWD' => 0.341279,
        'KYD' => 0.933557,
        'KZT' => 425.335474,
        'LAK' => 9635.908494,
        'LBP' => 1692.726415,
        'LKR' => 195.575736,
        'LRD' => 182.633689,
        'LSL' => 15.820568,
        'LTL' => 3.308411,
        'LVL' => 0.677752,
        'LYD' => 1.557714,
        'MAD' => 10.834861,
        'MDL' => 19.469579,
        'MGA' => 4028.034194,
        'MKD' => 61.653011,
        'MMK' => 1692.295748,
        'MNT' => 2946.8941,
        'MOP' => 9.058594,
        'MRO' => 400.002303,
        'MUR' => 39.270247,
        'MVR' => 17.322333,
        'MWK' => 811.192202,
        'MXN' => 21.547569,
        'MYR' => 4.583757,
        'MZN' => 71.687012,
        'NAD' => 16.381425,
        'NGN' => 402.805225,
        'NIO' => 36.806997,
        'NOK' => 9.638272,
        'NPR' => 123.681383,
        'NZD' => 1.659449,
        'OMR' => 0.431369,
        'PAB' => 1.120623,
        'PEN' => 3.711001,
        'PGK' => 3.781366,
        'PHP' => 58.800891,
        'PKR' => 157.2106,
        'PLN' => 4.296775,
        'PYG' => 6925.977711,
        'QAR' => 4.079855,
        'RON' => 4.759127,
        'RSD' => 117.927497,
        'RUB' => 73.222932,
        'RWF' => 1011.210147,
        'SAR' => 4.202096,
        'SBD' => 9.044423,
        'SCR' => 15.304848,
        'SDG' => 53.358845,
        'SEK' => 10.449437,
        'SGD' => 1.518967,
        'SHP' => 1.48001,
        'SLL' => 9960.840226,
        'SOS' => 650.984001,
        'SRD' => 8.356357,
        'STD' => 23_586.238141,
        'SVC' => 9.804368,
        'SYP' => 577.034069,
        'SZL' => 15.831518,
        'THB' => 35.608398,
        'TJS' => 10.574739,
        'TMT' => 3.932795,
        'TND' => 3.397274,
        'TOP' => 2.535308,
        'TRY' => 6.29682,
        'TTD' => 7.593264,
        'TWD' => 34.559325,
        'TZS' => 2588.696018,
        'UAH' => 30.451676,
        'UGX' => 4168.371087,
        'USD' => 1.120454,
        'UYU' => 37.530676,
        'UZS' => 9434.226678,
        'VEF' => 11.190541,
        'VND' => 25_993.98316,
        'VUV' => 128.013864,
        'WST' => 2.930086,
        'XAF' => 656.171492,
        'XAG' => 0.074109,
        'XAU' => 0.000867,
        'XCD' => 3.028084,
        'XDR' => 0.807946,
        'XOF' => 660.506639,
        'XPF' => 119.832687,
        'YER' => 280.505284,
        'ZAR' => 15.924349,
        'ZMK' => 10_085.442402,
        'ZMW' => 13.586621,
        'ZWL' => 361.184109 }
    end
    base { 'EUR' }
    updated_at { Date.today }
  end
end

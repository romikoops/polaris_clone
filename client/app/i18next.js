import i18n from 'i18next'
import LngDetector from 'i18next-browser-languagedetector'
import resources from '../locales'

i18n
  .use(LngDetector)
  .init({
    resources,
    fallbackLng: 'en',
    defaultLng: 'en',
    defaultNS: 'common',
    ns: ['account',
      'admin',
      'bookconf',
      'cargo',
      'cookies',
      'dangerousGoods',
      'doc',
      'errors',
      'footer',
      'help',
      'imc',
      'itbox',
      'landing',
      'common',
      'nav',
      'optout',
      'shipment',
      'trucking',
      'user'],
    debug: true,
    interpolation: {
      escapeValue: false,
      prefix: '{{',
      suffix: '}}'
    },
    react: {
      wait: true,
      bindI18n: 'languageChanged loaded',
      bindStore: 'added removed',
      nsMode: 'default'
    }
  })

export default i18n

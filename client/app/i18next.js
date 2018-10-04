import i18n from 'i18next'
import XHR from 'i18next-xhr-backend'
import LngDetector from 'i18next-browser-languagedetector'
import { reactI18nextModule } from 'react-i18next'

i18n
  .use(XHR)
  .use(LngDetector)
  .use(reactI18nextModule)
  .init({
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
    backend: {
      loadPath: '/{{lng}}/{{ns}}.json',
      crossDomain: true
    },
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

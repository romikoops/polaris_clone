import i18n from 'i18next'
import XHR from 'i18next-xhr-backend'
import LngDetector from 'i18next-browser-languagedetector'
import { reactI18nextModule } from 'react-i18next'

const loadPath = process.env.NODE_ENV === 'production' ?
  '/{{lng}}/{{ns}}.json' :
  'http://localhost:3004/{{lng}}/{{ns}}.json'

i18n
  .use(XHR)
  .use(LngDetector)
  .use(reactI18nextModule)
  .init({
    fallbackLng: 'en-US',
    defaultLng: 'en-US',
    defaultNS: 'common',
    ns: ['landing', 'common'],
    debug: true,
    backend: {
      loadPath,
      crossDomain: true
    },
    interpolation: {
      escapeValue: false
    },
    react: {
      wait: true,
      bindI18n: 'languageChanged loaded',
      bindStore: 'added removed',
      nsMode: 'default'
    }

  })

export default i18n

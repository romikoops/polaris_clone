import i18n from 'i18next'
// import FetchBackend from 'i18next-fetch-backend'
import XHR from 'i18next-xhr-backend'
import LngDetector from 'i18next-browser-languagedetector'
import { reactI18nextModule } from 'react-i18next'

// FetchBackend.type = 'backend'
i18n
  .use(XHR)
  // .use(FetchBackend)
  .use(LngDetector)
  .use(reactI18nextModule)
  .init({
    fallbackLng: 'en-US',
    defaultLng: 'en-US',
    defaultNS: 'common',
    ns: ['landing', 'common'],
    debug: true,
    backend: {
      // loadPath: 'https://localhost:3000/translations/{{lng}}/{{ns}}.json',
      loadPath: 'https://translations.itsmycargo.com/{{lng}}/{{ns}}.json',
      // init: {
      //   mode: 'cors',
      //   // credentials: 'same-origin',
      //   cache: 'default'
      // },
      crossDomain: true
    },
    interpolation: {
      escapeValue: false
    },
    // . // if not using I18nextProvider
    // react i18next special options (optional)
    react: {
      wait: true,
      bindI18n: 'languageChanged loaded',
      bindStore: 'added removed',
      nsMode: 'default'
    }

  })

export default i18n

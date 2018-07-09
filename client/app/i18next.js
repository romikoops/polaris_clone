import i18n from 'i18next'
import FetchBackend from 'i18next-fetch-backend'
import LngDetector from 'i18next-brng'
import { reactI18nextModule } from 'react-i18next'

​FetchBackend.type = 'backend'
​
i18n
  .use(FetchBackend)
  .use(LngDetector)
  .use(reactI18nextModule) // if not using I18nextProvider
  .init({
    fallbackLng: 'en',
    debug: true,
​    backend: {
      loadPath: '/locales/{{lng}}/{{ns}}.json',
    },
    interpolation: {
      escapeValue: false, // not needed for react!!
    },
​
    // react i18next special options (optional)
    react: {
      wait: false,
      bindI18n: 'languageChanged loaded',
      bindStore: 'added removed',
      nsMode: 'default'
    }
  });
​
​
export default i18n;
import React from 'react'
import { ConsentManager, openConsentManager } from '@itsmycargo/consent-manager'
import inEU from '@segment/in-eu'
import styles from './index.scss'

export default function (props) {
  const { writeKey } = props
  const { location } = window
  const { host } = location

  const openConsent = (event) => {
    event.preventDefault()

    openConsentManager()

    return false
  }

  const bannerContent = (
    <div>
      <div>
        <strong>About Cookies On This Site</strong>
      </div>
      <br />
      <div>
        <span>
          By clicking “Accept”, you agree to the use of ItsMyCargo and third-party cookies and
          other similar technologies to enhance your browsing experience, analyze and
          measure your engagement with our content. Learn more about your
          {' '}
          <a href="#" onClick={openConsent}>choices</a>
          {' '}
          and
          {' '}
          <a href="https://www.itsmycargo.com/en/privacy" target="_blank">cookies</a>
          .
        </span>
      </div>
    </div>
  )

  const bannerSubContent = ''
  const preferencesDialogTitle = 'Website Data Collection Preferences'
  const preferencesDialogContent = 'We use data collected by cookies and JavaScript libraries to improve your browsing experience, analyze site traffic, deliver personalized advertisements, and increase the overall performance of our site.'

  const cancelDialogTitle = 'Are you sure you want to cancel?'
  const cancelDialogContent = 'Your preferences have not been saved. By continuing to use our website, you՚re agreeing to our Website Data Collection Policy.'

  return (
    <div className={styles.ConsentManager}>
      <ConsentManager
        writeKey={writeKey}
        shouldRequireConsent={inEU}
        closeBehavior="accept"
        cookieDomain={host}
        bannerContent={bannerContent}
        bannerSubContent={bannerSubContent}
        preferencesDialogTitle={preferencesDialogTitle}
        preferencesDialogContent={preferencesDialogContent}
        cancelDialogTitle={cancelDialogTitle}
        cancelDialogContent={cancelDialogContent}
      />
    </div>
  )
}

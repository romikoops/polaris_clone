import React from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { withGTM } from 'react-tag-manager'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import { ROW, trim, COLUMN } from '../../classNames'
import setCookie from './_modules/setCookie'
import getCookie from './_modules/getCookie'

const sampleData = {
  title: 'This site use cookies',
  description: trim(`
  We and our advertising partners
  use these cookies to deliver advertisements,
  to make them more relevant and meaningful
  to visitors to our website, and to track
  the efficiency of our advertising campaigns,
  both on our services and on other websites.
  `),
  modalTitle: 'Cookie declaration',
  modalDescription: trim(`
  We use cookies to personalize content and ads,
  to provide social media features and to analyze
  our traffic.
  `),
  modalMandatory: trim(`
  These cookies are necessary for the Website to function and cannot be turned off in our systems. They are usually only set in response to actions made by you which amount to a request for information or services, such as logging in or filling in forms on our Website.
  `),
  modalAnalytics: trim(`
  These cookies enable us to provide enhanced functionality and personalization for our website. They may be set by us or by third party providers whose services we have added to our pages.
  `),
  modalMarketing: trim(`
  These cookies may be set through our site by our advertising partners. They may be used by those companies to build a profile of your interests and show you relevant adverts on other websites.
  `)
}

const MODAL = `${styles.modal} ${COLUMN(100)}`
const MODAL_TITLE = `${COLUMN(50)} ${styles.modal_title}`
const MODAL_DESCRIPTION = `${COLUMN(50)} ${
  styles.modal_description
}`
const MODAL_SECTION_TEXT = `${ROW(80)} ${styles.modal_section_text}`
const MODAL_SECTION_TITLE = `${COLUMN(10)} ${
  styles.modal_section_title
}`
const MODAL_SECTION_BUTTON = `${ROW(35)} ${
  styles.modal_section_button
}`
const LEARN_MORE = `${ROW(20)} ${styles.show_details}`
const TOGGLE = `${styles.mandatory} fa fa-3x fa-toggle-on`

function getToggleStyle (flag) {
  const base = 'fa fa-3x'
  const active = flag
    ? styles.active
    : styles.inactive
  const on = flag
    ? 'fa-toggle-on'
    : 'fa-toggle-off'

  return `${base} ${active} ${on}`
}

class PureCookieConsentBar extends React.PureComponent {
  constructor (props) {
    super(props)
    const consent = JSON.parse(getCookie('consent') || '{}')
    const accepted = consent.mandatory === true

    this.state = {
      accepted,
      consent,
      analyticsSelected: true,
      marketingSelected: true
    }
    this.toggleMarketing = this.toggleMarketing.bind(this)
    this.toggleAnalytics = this.toggleAnalytics.bind(this)
    this.accept = this.accept.bind(this)
  }

  toggleAnalytics () {
    this.setState(prevState => ({
      analyticsSelected: !prevState.analyticsSelected
    }))
  }

  toggleMarketing () {
    this.setState(prevState => ({
      marketingSelected: !prevState.marketingSelected
    }))
  }

  accept () {
    const consent = {
      mandatory: true,
      analytics: this.state.analyticsSelected,
      marketing: this.state.marketingSelected
    }

    this.setState({
      accepted: true,
      consent
    }, () => this.pushEvents())
    setCookie('consent', JSON.stringify(consent))
  }

  pushEvents () {
    const { GTM } = this.props

    if (this.state.consent.mandatory) { GTM.api.trigger({ event: 'consent_mandatory', consent_mandatory: '1' }) }
    if (this.state.consent.analytics) { GTM.api.trigger({ event: 'consent_analytics', consent_analytics: '1' }) }
    if (this.state.consent.marketing) { GTM.api.trigger({ event: 'consent_marketing', consent_marketing: '1' }) }
  }

  render () {
    const {
      t,
      tenant
    } = this.props

    const {
      accepted,
      analyticsSelected,
      marketingSelected
    } = this.state

    if (accepted || !tenant) return ''

    return (
      <React.Fragment>
        <div className={styles.modal_background} />

        <div className={MODAL}>
          <div className={COLUMN(20)}>
            <div className={COLUMN(100)}>
              <div className={MODAL_TITLE}>
                {sampleData.modalTitle}
              </div>
              <div className={MODAL_DESCRIPTION}>
                {sampleData.modalDescription}
              </div>
            </div>
          </div>

          <div className={styles.modal_separator} />

          <div className={MODAL_SECTION_TITLE}>Mandatory</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalMandatory}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  className={TOGGLE}
                />
              </div>
            </div>
          </div>

          <div className={MODAL_SECTION_TITLE}>{t('common:marketing')}</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalMarketing}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  onClick={this.toggleMarketing}
                  className={getToggleStyle(marketingSelected)}
                />
              </div>
            </div>
          </div>

          <div className={MODAL_SECTION_TITLE}>{t('common:analytics')}</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalAnalytics}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  onClick={this.toggleAnalytics}
                  className={getToggleStyle(analyticsSelected)}
                />
              </div>
            </div>
          </div>

          <div className={styles.modal_separator} />

          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={ROW(60)} />
              <div className={LEARN_MORE}>
                <a
                  href="https://www.itsmycargo.com/en/privacy"
                  target="_blank"
                >
                  {t('common:learnMore')}
                </a>
              </div>
              <div className={ROW(20)}>
                <button
                  className={styles.accept_all}
                  type="button"
                  onClick={this.accept}
                >
                  <i className="fa fa-check" />
                  {t('common:accept')}
                </button>
              </div>
            </div>
          </div>
        </div>
      </React.Fragment>
    )
  }
}

PureCookieConsentBar.propTypes = {
  t: PropTypes.func.isRequired,
  tenant: PropTypes.tenant
}

PureCookieConsentBar.defaultProps = {
  tenant: null
}

function mapStateToProps (state) {
  return state.cookie
}

@withGTM
@connect(mapStateToProps)
class CookieConsentBar extends PureCookieConsentBar {}

export const TPureCookieConsentBar = withNamespaces()(PureCookieConsentBar)
export default withNamespaces()(CookieConsentBar)

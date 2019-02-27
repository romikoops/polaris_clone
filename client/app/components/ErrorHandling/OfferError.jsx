import React, { PureComponent } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { get, has } from 'lodash'
import { withNamespaces } from 'react-i18next'
import { errorActions } from '../../actions'
import styles from './errors.scss'
import CircleCompletion from '../CircleCompletion/CircleCompletion'

class OfferError extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      defaultError: {
        type: '',
        code: '',
        title: '',
        addtionalInfo: ''
      }
    }
  }

  determineErrorContent () {
    const {
      error, t, componentName
    } = this.props
    const { defaultError } = this.state
    const errorToRender = get(error, [componentName], defaultError)
    const { targetAddress, target } = errorToRender
    switch (String(errorToRender.code)) {
      case '1101': {
        const prep = target === 'origin' ? 'from' : 'to'

        return (
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            <p className="flex-100">{t('errors:offerErrorTrucking', { prep })}</p>
            <p className={`flex-100 ${styles.error_address}`}>{targetAddress}</p>
          </div>
        )
      }
      default: {
        return (
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            <p className="flex-100">{errorToRender.message}</p>
          </div>
        )
      }
    }
  }

  determineContactInfoToRender () {
    const { tenant, availableMots, t } = this.props
    const content = {
      emails: [],
      phones: []
    }
    if (!tenant) { return '' }

    Object.keys(get(tenant, ['emails', 'sales'], get(tenant, ['emails', 'support'], {})))
      .filter(k => k !== 'general')
      .forEach((key) => {
        const contactData = get(tenant, ['emails', 'sales', key], get(tenant, ['emails', 'support', key], ''))
        if (contactData) {
          content.emails.push(

            <div key={`offer-emails-${key}`} className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${styles.contact_detail_section}`}>
              <p className="flex-none">{t('user:email')}</p>
              <a href={`mailto:${contactData}`} className="flex-none pointy">{contactData}</a>
            </div>

          )
        }
      })
    const contactData = get(tenant, ['phones', 'main'], false)
    if (contactData) {
      content.phones.push(

        <div key="offer-phones-last" className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${styles.contact_detail_section}`}>
          <p className="flex-none">{t('user:phone')}</p>
          <a href={`tel:${contactData}`} className="flex-none pointy">{contactData}</a>
        </div>

      )
    }

    if (content.emails.length < 1) {
      const contactData = get(tenant, ['emails', 'sales', 'general'], get(tenant, ['emails', 'support', 'general'], ''))
      if (contactData) {
        content.emails.push(

          <div key="offer-emails-last" className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${styles.contact_detail_section}`}>
            <p className="flex-none">{t('user:email')}</p>
            <a href={`mailto:${contactData}`} className="flex-none">{contactData}</a>
          </div>

        )
      }
    }

    return [...content.emails, ...content.phones]
  }

  closeDrawer () {
    const { errorDispatch, error, componentName } = this.props
    const errorToClear = { ...error, componentName }
    errorDispatch.clearError(errorToClear)
  }

  render () {
    const {
      error,
      tenant,
      t,
      componentName
    } = this.props
    const { defaultError } = this.state
    const wrapperStyle = has(error, [componentName, 'code']) ? styles.show_error_drawer : styles.hide_error_drawer

    const {
      code, side
    } = get(error, [componentName], defaultError)
    const sideStyle = styles[`error_${side}`]

    return (
      <div className={`flex-none layout-row layout-align-center-start layout-wrap ${wrapperStyle} ${sideStyle}`}>
        <div className={`flex-none layout-row layout-align-center-start layout-wrap ${styles.error_content}`}>
          <div className={`flex-100 layout-row layout-align-end ${styles.close_row}`}>
            <div
              className={`flex-none layout-row layout-align-center-center ${styles.close_drawer}`}
              onClick={() => this.closeDrawer()}
            >
              <i className="fa fa-times flex-none" />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-center layout-wrap">
            <CircleCompletion
              icon="fa fa-phone"
              iconColor="white"
              animated
              size="100px"
              margin="15px"
              opacity="1"
            />
            <h3 className="flex-100 center">{ t('errors:offerErrorTitle') }</h3>
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap">
            { this.determineErrorContent()}
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <p className="flex-100">{t('errors:offerErrorContact', { tenant })}</p>
            </div>
            <div className="flex-100 layout-row layout-align-center-start layout-wrap">
              {this.determineContactInfoToRender()}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-end layout-wrap">
            <div className="flex-100 layout-row layout-align-start-end">
              <p className="flex-100">{t('errors:offerErrorCode', { code })}</p>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const {
    error,
    app
  } = state
  const { tenant } = app

  return {
    tenant,
    error
  }
}
function mapDispatchToProps (dispatch) {
  return {
    errorDispatch: bindActionCreators(errorActions, dispatch)
  }
}

export default withNamespaces(['errors', 'user'])(connect(mapStateToProps, mapDispatchToProps)(OfferError))

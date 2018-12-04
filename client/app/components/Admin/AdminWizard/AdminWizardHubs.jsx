import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminHubTile } from '../'
import { history } from '../../../helpers'
import { RoundButton } from '../../RoundButton/RoundButton'
import FileUploader from '../../../components/FileUploader/FileUploader'
import TextHeading from '../../TextHeading/TextHeading'

export class AdminWizardHubs extends Component {
  static back () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.nextStep = this.nextStep.bind(this)
    this.back = this.back.bind(this)
  }
  nextStep () {
    this.props.adminTools.goTo('/admin/wizard/service_charges')
  }
  render () {
    const {
      theme, newHubs, adminTools, t
    } = this.props
    let hubList
    if (newHubs && newHubs.length > 0) {
      hubList = newHubs.map(hub => (
        <AdminHubTile
          key={v4()}
          hub={hub}
          theme={theme}
          handleClick={() => adminTools.getHub(hub.id, true)}
        />
      ))
    } else {
      hubList = []
    }
    const hubUrl = '/admin/hubs/process_csv'
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('common:basicBack')}
          handleNext={AdminWizardHubs.back}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    const nextButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          active
          text={t('common:next')}
          handleNext={this.nextStep}
          iconClass="fa-chevron-right"
        />
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
            <TextHeading theme={theme} size={2} text={t('admin:hubs')} />
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
          >
            <p className="flex-none">{t('admin:uploadHubs')}</p>
            <FileUploader
              theme={theme}
              url={hubUrl}
              dispatchFn={adminTools.wizardHubs}
              type="xlsx"
              text="Hub .xlsx"
            />
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">{hubList}</div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
          >
            {backButton}
            {nextButton}
          </div>
        </div>
      </div>
    )
  }
}
AdminWizardHubs.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  adminTools: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired,
  newHubs: PropTypes.arrayOf(PropTypes.hub)
}

AdminWizardHubs.defaultProps = {
  theme: null,
  newHubs: []
}

export default withNamespaces(['admin', 'common'])(AdminWizardHubs)

import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
// import { AdminHubTile } from '../';
import { RoundButton } from '../../RoundButton/RoundButton'
// import {v4} from 'node-uuid';
import FileUploader from '../../../components/FileUploader/FileUploader'
import history from '../../../helpers'

export class AdminWizardServiceCharges extends Component {
  static back () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.nextStep = this.nextStep.bind(this)
  }
  nextStep () {
    this.props.adminTools.goTo('/admin/wizard/pricings')
  }
  render () {
    const { theme, adminTools } = this.props
    const scUrl = '/admin/hubs/process_csv'
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={AdminWizardServiceCharges.back}
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
          text="Next"
          handleNext={this.nextStep}
          iconClass="fa-chevron-right"
        />
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
              Service Charges
            </p>
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
          >
            <p className="flex-none">Upload Service Charge Sheet</p>
            <FileUploader
              theme={theme}
              url={scUrl}
              dispatchFn={adminTools.wizardSCharge}
              type="xlsx"
              text="Hub .xlsx"
            />
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {/* {hubList} */}
          </div>
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
AdminWizardServiceCharges.propTypes = {
  theme: PropTypes.theme,
  adminTools: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired
}

AdminWizardServiceCharges.defaultProps = {
  theme: null
}

export default AdminWizardServiceCharges

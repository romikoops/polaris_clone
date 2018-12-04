import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
// import { AdminHubTile } from '../';
// import { RoundButton } from '../../RoundButton/RoundButton';
// import {v4} from 'uuid';
// import Select from 'react-select';
// import '../../../styles/select-css-custom.scss';
// import styled from 'styled-components';
// import FileUploader from '../../../components/FileUploader/FileUploader';
export class AdminWizardFinished extends Component {
  constructor (props) {
    super(props)
    this.nextStep = this.nextStep.bind(this)
  }
  nextStep () {
    this.props.adminTools.goTo('/admin/wizard/finished')
  }

  render () {
    const { theme, t } = this.props
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
            <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
              {t('admin:finished')}
            </h1>
          </div>

          <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
              {t('admin:browseLinks')}
            </p>
          </div>
        </div>
      </div>
    )
  }
}
AdminWizardFinished.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  adminTools: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired
}

AdminWizardFinished.defaultProps = {
  theme: null
}

export default withNamespaces('admin')(AdminWizardFinished)

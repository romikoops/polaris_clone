import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import AdminPromptConfirm from '../Prompt/Confirm'
import Checkbox from '../../Checkbox/Checkbox'
import { gradientTextGenerator } from '../../../helpers'

class MandatoryChargeBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      mandatoryCharge: {}
    }
  }
  componentWillReceiveProps (nextProps) {
    if (nextProps.mandatoryCharge && nextProps.mandatoryCharge.id !== this.state.mandatoryCharge.id) {
      this.setState({ mandatoryCharge: nextProps.mandatoryCharge })
    }
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  confirmSave (target) {
    this.setState({ confirm: true })
  }
  closeAndSave () {
    const { saveChanges } = this.props
    const { mandatoryCharge } = this.state
    saveChanges(mandatoryCharge)
    this.closeConfirm()
  }
  handleToggle (ev, key) {
    this.setState({
      mandatoryCharge: {
        ...this.state.mandatoryCharge,
        [key]: !this.state.mandatoryCharge[key]
      }
    })
  }

  render () {
    const { mandatoryCharge, confirm } = this.state
    const {
      theme, t
    } = this.props
    if (!mandatoryCharge.id) return ''

    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:instantlyAvailable')}
        confirm={() => this.closeAndSave()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const iconTheme =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : 'black'
    const editHasOccureed = mandatoryCharge.import_charges !== this.props.mandatoryCharge.import_charges ||
    mandatoryCharge.export_charges !== this.props.mandatoryCharge.export_charges

    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        { confimPrompt }
        <div className={`flex-100 layout-row layout-align-start-center layout-wrap ${styles.mandatory_charges_box}`}>
          <div className={`flex-75 layout-row layout-align-space-around-center ${styles.charges_row_padding}`}>
            <p className="flex-none">{t('admin:importFees')}</p>
            <Checkbox
              id="import"
              theme={theme}
              name="import"
              checked={mandatoryCharge.import_charges}
              onChange={e => this.handleToggle(e, 'import_charges')}
            />
          </div>
          <div className={`flex-75 layout-row layout-align-space-around-center ${styles.charges_row_padding}`}>
            <p className="flex-none">{t('admin:exportFees')}</p>
            <Checkbox
              id="export"
              theme={theme}
              name="export"
              checked={mandatoryCharge.export_charges}
              onChange={e => this.handleToggle(e, 'export_charges')}
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-end-center">
          {editHasOccureed ? (
            <div className={`${styles.save_icon_btn} flex-none layout-row layout-align-end-center pointy`} onClick={() => this.confirmSave()}>
              <p className="flex-none">{t('admin:save')}</p>
              <div className={`${styles.save_icon_btn} flex-none layout-row pointy`}>
                <i className="fa fa-floppy-o clip" style={iconTheme} />
              </div>
            </div>
          ) : (
            ''
          )}
        </div>
      </div>
    )
  }
}

MandatoryChargeBox.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme.isRequired,
  saveChanges: PropTypes.func.isRequired,
  mandatoryCharge: PropTypes.func.isRequired
}
MandatoryChargeBox.defaultProps = {}
export default withNamespaces(['admin', 'common]'])(MandatoryChargeBox)

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { serviceChargeNames } from '../../constants/admin.constants'

export class AdminImportChargePanel extends Component {
  constructor (props) {
    super(props)
    this.handleLink = this.handleLink.bind(this)
    this.toggleExpand = this.toggleExpand.bind(this)
  }
  handleLink () {
    const { target, navFn } = this.props
    navFn(target)
  }
  toggleExpand () {
    this.props.backFn()
  }
  render () {
    // const { expanded } = this.state;
    const {
      t, theme, hub, charge
    } = this.props
    if (!hub || !charge) {
      return ''
    }
    const gradientStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})`
          : 'black'
    }
    const importArr = []
    const ChargeSection = ({ tag, value, currency }) => (
      <div className={`flex-90 layout-row layout-align-space-between-center ${styles.charge_opt}`}>
        <p className="flex-none"> {serviceChargeNames[tag]}</p>
        <p className="flex-none">
          {' '}
          {value} {currency}
        </p>
      </div>
    )
    Object.keys(charge).forEach((key) => {
      // ;
      if (charge[key] && charge[key].trade_direction && charge[key].trade_direction === 'import') {
        // ;
        importArr.push(<ChargeSection
          key={v4()}
          tag={key}
          value={charge[key].value}
          currency={charge[key].currency}
        />)
      }
    })

    return (
      <div className={`flex-100 ${styles.charge_card} layout-row layout-wrap`}>
        <div className={`${styles.charge_header} layout-row layout-wrap flex-100`}>
          {/* <div className={`flex-none ${styles.fade}`}></div> */}
          <div className={`flex-100 ${styles.content} layout-row`}>
            <div className="flex-10 layout-column layout-align-center-start">
              <i className="flex-none fa fa-map-marker" style={gradientStyle} />
            </div>
            <div className="flex-80 layout-row layout-wrap layout-align-start-start">
              <h3 className="flex-100" style={gradientStyle}>
                {' '}
                {hub.data.name}{' '}
              </h3>
            </div>
            <div
              className="flex-10 layout-column layout-align-start-center"
              onClick={this.toggleExpand}
            >
              {/* <p className="flex-none" style={gradientStyle}>Back</p> */}
            </div>
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-start ${
            styles.charge_panel
          }`}
        >
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-start ${
              styles.charge_panel_xxport
            }`}
          >
            <div className="flex-100 layout-row layout-align-start-start">
              <h3 className="flex-none offset-5">{t('admin:import')}</h3>
            </div>
            <div className="flex-100 layout-row layout-align-center-start layout-wrap">
              {importArr}
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminImportChargePanel.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hub: PropTypes.hub,
  charge: PropTypes.objectOf(PropTypes.shape({
    trade_direction: PropTypes.string,
    value: PropTypes.string,
    currency: PropTypes.string
  })),
  navFn: PropTypes.func.isRequired,
  backFn: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired
}

AdminImportChargePanel.defaultProps = {
  theme: null,
  hub: null,
  charge: null
}

export default withNamespaces('admin')(AdminImportChargePanel)

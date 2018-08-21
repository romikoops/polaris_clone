import React, { Component } from 'react'
import { translate } from 'react-i18next'
import styles from './CargoItemDetails.scss'
import PropTypes from '../../prop-types'
import { HsCodeViewer } from '../HsCodes/HsCodeViewer'

export class CargoItemDetails extends Component {
  constructor (props) {
    super(props)
    this.state = {
      viewer: false
    }
    this.viewHsCodes = this.viewHsCodes.bind(this)
  }
  viewHsCodes () {
    this.setState({
      viewer: !this.state.viewer
    })
  }
  render () {
    const { viewer } = this.state
    const {
      hsCodes,
      index,
      item,
      t,
      theme,
      viewHSCodes
    } = this.props

    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${
            theme.colors.primary
          },${
            theme.colors.secondary
          })`
          : 'black'
    }

    return (
      <div className={`${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
        <div className="flex-100">
          <h4>{`${t('common:unit')} ${index + 1}`}</h4>
        </div>
        <hr />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:grossWeight')}</p>
          <p>{item.payload_in_kg} kg</p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:length')}</p>
          <p>{item.dimension_y} cm</p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:width')}</p>
          <p>{item.dimension_x} cm</p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:height​​')}</p>
          <p>{item.dimension_z} cm</p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:volume')}</p>
          <p>
            {(item.dimension_y * item.dimension_x * item.dimension_y / 1000000).toFixed(2)} m<sup>
              3
            </sup>
          </p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:chargeableWeight')}</p>
          <p>
            {(item.chargeable_weight).toFixed(2)} kg
          </p>
        </div>
        <hr className="flex-100" />
        {viewHSCodes ? (
          <div className="flex-100 layout-row layout-wrap" onClick={this.viewHsCodes}>
            <i className="fa fa-eye clip flex-none" style={textStyle} />
            <p className="offset-5 flex-none">{t('common:viewHsCodes')}</p>
          </div>
        ) : (
          ''
        )}
        {viewer ? (
          <HsCodeViewer item={item} hsCodes={hsCodes} theme={theme} close={this.viewHsCodes} />
        ) : (
          ''
        )}
      </div>
    )
  }
}

CargoItemDetails.propTypes = {
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired,
  index: PropTypes.number.isRequired,
  theme: PropTypes.theme,
  viewHSCodes: PropTypes.bool,
  item: PropTypes.shape({
    hs_codes: PropTypes.array
  }).isRequired
}

CargoItemDetails.defaultProps = {
  viewHSCodes: false,
  theme: false
}

export default translate('common')(CargoItemDetails)

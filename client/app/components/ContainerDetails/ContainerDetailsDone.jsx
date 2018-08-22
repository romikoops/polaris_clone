import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { CONTAINER_DESCRIPTIONS } from '../../constants'
import styles from './ContainerDetails.scss'
import PropTypes from '../../prop-types'
import { HsCodeViewer } from '../HsCodes/HsCodeViewer'

export class ContainerDetails extends Component {
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
    const cDesc = CONTAINER_DESCRIPTIONS
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
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }

    return (
      <div className={` ${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
        <div className="flex-100 layout-row">
          <h4>{`${t('common:unit')} ${index + 1}`}</h4>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:grossWeight')}</p>
          <p>{item.payload_in_kg} kg</p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:containerClass')}</p>
          <p>{cDesc[item.size_class]} </p>
        </div>
        <hr className="flex-100" />
        <div className="flex-100 layout-row layout-align-space-between">
          <p>{t('common:numberContainers')}</p>
          <p>{item.quantity} </p>
        </div>
        <hr className="flex-100" />
        {viewHSCodes ? (
          <div className="flex-100 layout-row layout-wrap" onClick={this.viewHsCodes}>
            <i className="fa fa-eye clip flex-none" style={textStyle} />
            <p className="offset-5 flex-none">
              {t('common:viewHsCodes')}
            </p>
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

ContainerDetails.propTypes = {
  hsCodes: PropTypes.arrayOf(PropTypes.string),
  index: PropTypes.number.isRequired,
  theme: PropTypes.theme,
  viewHSCodes: PropTypes.bool,
  item: PropTypes.shape({
    payload_in_kg: PropTypes.number,
    quantity: PropTypes.number,
    size_class: PropTypes.string
  }).isRequired
}

ContainerDetails.defaultProps = {
  hsCodes: [],
  theme: null,
  viewHSCodes: false
}

export default translate('common')(ContainerDetails)

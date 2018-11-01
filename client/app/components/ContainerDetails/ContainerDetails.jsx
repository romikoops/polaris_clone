import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { CONTAINER_DESCRIPTIONS } from '../../constants'
import styles from './ContainerDetails.scss'
import PropTypes from '../../prop-types'
import HsCodeViewer from '../HsCodes/HsCodeViewer'

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
    const {
      index, item, hsCodes, theme, viewHSCodes, t
    } = this.props
    const { viewer } = this.state
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }

    return (
      <div className={` ${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
        <div className="flex-100 layout-row">
          <h4>{t('common:unit')} {index + 1}</h4>
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
ContainerDetails.propTypes = {
  item: PropTypes.shape({
    payload_in_kg: PropTypes.number,
    size_class: PropTypes.string,
    quantity: PropTypes.number
  }).isRequired,
  t: PropTypes.func.isRequired,
  index: PropTypes.number.isRequired,
  hsCodes: PropTypes.arrayOf(PropTypes.string),
  theme: PropTypes.theme,
  viewHSCodes: PropTypes.bool
}

ContainerDetails.defaultProps = {
  theme: null,
  hsCodes: [],
  viewHSCodes: false
}

export default withNamespaces('common')(ContainerDetails)

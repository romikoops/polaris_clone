import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { CONTAINER_DESCRIPTIONS } from '../../constants'
import styles from './ContainerDetails.scss'
import PropTypes from '../../prop-types'
import { HsCodeViewer } from '../HsCodes/HsCodeViewer'
import { ROW, WRAP_ROW } from '../../classNames'

const CONTAINER = `CONTAINER_DETAILS ${styles.info} ${WRAP_ROW(100)} layout-align-center`
const EYE_ICON = 'fa fa-eye clip flex-none'

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

    const textStyle = textStyleFn(theme)

    const ViewHsCodes = () => {
      if (!viewHSCodes) return ''

      return (
        <div className={WRAP_ROW(100)} onClick={this.viewHsCodes}>
          <i className={EYE_ICON} style={textStyle} />
          <p className="offset-5 flex-none">View Hs Codes</p>
        </div>
      )
    }

    const HsCodeViewerComponent = () => {
      if (!viewer) return ''

      return (
        <HsCodeViewer
          item={item}
          hsCodes={hsCodes}
          theme={theme}
          close={this.viewHsCodes}
        />
      )
    }

    return (
      <div className={CONTAINER}>
        <div className={ROW(100)}>
          <h4>{t('common:unit')} {index + 1}</h4>
        </div>

        <hr className="flex-100" />

        <div className={`${ROW(100)} layout-align-space-between`}>
          <p>{t('common:grossWeight')}</p>
          <p>{item.payload_in_kg} kg</p>
        </div>

        <hr className="flex-100" />

        <div className={`${ROW(100)} layout-align-space-between`}>
          <p>{t('common:containerClass')}</p>
          <p>{cDesc[item.size_class]} </p>
        </div>

        <hr className="flex-100" />

        <div className={`${ROW(100)} layout-align-space-between`}>
          <p>{t('common:numberContainers')}</p>
          <p>{item.quantity} </p>
        </div>

        <hr className="flex-100" />

        {ViewHsCodes()}

        {HsCodeViewerComponent()}
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
  index: PropTypes.number.isRequired,
  hsCodes: PropTypes.arrayOf(PropTypes.string),
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  viewHSCodes: PropTypes.bool
}

ContainerDetails.defaultProps = {
  theme: null,
  hsCodes: [],
  viewHSCodes: false
}

function textStyleFn (theme) {
  return {
    background:
      theme && theme.colors
        ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
        : 'black'
  }
}

export default translate('common')(ContainerDetails)

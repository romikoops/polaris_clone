import React, { Component } from 'react'
import styles from './CargoItemDetails.scss'
import PropTypes from '../../prop-types'
import { HsCodeViewer } from '../HsCodes/HsCodeViewer'
import { trim, ROW, WRAP_ROW } from '../../classNames'

const CONTAINER = trim(`
  CARGO_ITEM_DETAILS
  ${styles.info} 
  ${WRAP_ROW(100)} 
  layout-align-center
`)
const LONG_ROW = 'flex-100 layout-row layout-align-space-between'

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
      theme,
      viewHSCodes
    } = this.props

    const textStyle = textStyleFn(theme)
    const HSCodes = () => {
      if (!viewHSCodes) {
        return ''
      }

      return (
        <div className={WRAP_ROW(100)} onClick={this.viewHsCodes}>
          <i className="fa fa-eye clip flex-none" style={textStyle} />
          <p className="offset-5 flex-none">View Hs Codes</p>
        </div>
      )
    }
    const Viewer = () => {
      if (!viewer) {
        return ''
      }

      return (
        <HsCodeViewer
          item={item}
          hsCodes={hsCodes}
          theme={theme}
          close={this.viewHsCodes}
        />
      )
    }

    const dimensions = dimensionsFn(item)

    return (
      <div className={CONTAINER}>
        <div className="flex-100">
          <h4>Unit {index + 1}</h4>
        </div>

        <hr />

        <div className={LONG_ROW}>
          <p>Gross Weight</p>
          <p>{item.payload_in_kg} kg</p>
        </div>

        <hr className="flex-100" />

        <div className={LONG_ROW}>
          <p>Length</p>
          <p>{item.dimension_y} cm</p>
        </div>

        <hr className="flex-100" />

        <div className={LONG_ROW}>
          <p>Width</p>
          <p>{item.dimension_x} cm</p>
        </div>

        <hr className="flex-100" />

        <div className={LONG_ROW}>
          <p>Height</p>
          <p>{item.dimension_z} cm</p>
        </div>

        <hr className="flex-100" />

        <div className={LONG_ROW}>
          <p>Volume</p>
          <p>
            {dimensions} m<sup>3</sup>
          </p>
        </div>

        <hr className="flex-100" />

        <div className={LONG_ROW}>
          <p>Chargeable Weight</p>
          <p>
            {(item.chargeable_weight).toFixed(2)} kg
          </p>
        </div>

        <hr className="flex-100" />

        {HSCodes()}

        {Viewer()}
      </div>
    )
  }
}
CargoItemDetails.propTypes = {
  item: PropTypes.shape({
    hs_codes: PropTypes.array
  }).isRequired,
  index: PropTypes.number.isRequired,
  viewHSCodes: PropTypes.bool,
  theme: PropTypes.theme,
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired
}

CargoItemDetails.defaultProps = {
  viewHSCodes: false,
  theme: false
}

function textStyleFn (theme) {
  return {
    background:
      theme && theme.colors
        ? `-webkit-linear-gradient(left, ${
          theme.colors.primary
        },${
          theme.colors.secondary
        })`
        : 'black'
  }
}

function dimensionsFn (item) {
  const dimensions = item.dimension_y * item.dimension_x * item.dimension_y

  return (dimensions / 1000000).toFixed(2)
}

export default CargoItemDetails

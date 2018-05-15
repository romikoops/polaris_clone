import React, { Component } from 'react'
import Toggle from 'react-toggle'
import { v4 } from 'node-uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import PropTypes from '../../../../prop-types'
import { HsCodeViewer } from '../../../HsCodes/HsCodeViewer'
import { gradientTextGenerator } from '../../../../helpers'
import CargoItemGroupAggregated from './Aggregated'

export class CargoItemGroup extends Component {
  constructor (props) {
    super(props)
    this.state = {
      viewer: false,
      unitView: false
    }
    this.viewHsCodes = this.viewHsCodes.bind(this)
  }
  viewHsCodes () {
    this.setState({
      viewer: !this.state.viewer
    })
  }
  handleViewToggle (value) {
    this.setState({ unitView: !this.state.unitView })
  }
  render () {
    const {
      group, hsCodes, theme, viewHSCodes
    } = this.props
    const { viewer, unitView } = this.state
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.brightSecondary} 100%
        ) !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: rgba(0, 0, 0, 0.75);
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const unitArr = group.items.map((item, i) => (
      <div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none" style={{ fontSize: '10px' }}>{`Item ${i}`}</p>
        </div>
        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Length</p>
          <p className="flex-none">{item.dimension_y} cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Width</p>
          <p className="flex-none">{item.dimension_x} cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Height</p>
          <p className="flex-none">{item.dimension_z} cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Gross Weight</p>
          <p className="flex-none">{item.payload_in_kg} kg</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Volume</p>
          <p className="flex-none">
            {(item.dimension_y * item.dimension_x * item.dimension_y / 1000000).toFixed(2)} m<sup>
              3
            </sup>
          </p>
        </div>
        <div className={`${styles.unit_data_cell} flex-33 layout-row layout-align-space-between`}>
          <p className="flex-none">Chargeable Weight</p>
          <p className="flex-none">{(item.chargeable_weight * 1000).toFixed(2)} kg</p>
        </div>
        <hr className="flex-100" />
      </div>
    ))
    const unitStyle = unitView ? styles.open_panel : styles.closed_panel
    const aggStyle = unitView ? styles.closed_panel : styles.open_panel
    const unitViewer = (
      <div
        className={`${unitStyle} ${
          styles.panel
        } flex-100 layout-row layout-wrap layout-align-none-center layout-wrap`}
      >
        {unitArr}
      </div>
    )
    const aggViewer = (
      <div
        className={`${aggStyle} ${
          styles.panel
        } flex-100 layout-row layout-wrap layout-align-none-center layout-wrap`}
      >
        <CargoItemGroupAggregated group={group} />
      </div>
    )
    return (
      <div className={`${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-40 layout-row layout-align-start-center">
            <h5 className="flex-none">Cargo Unit</h5>
            <div className="flex-5" />
            <p className="flex-none">{group.groupAlias}</p>
          </div>
          <div className="flex-40 layout-row layout-align-end-center">
            <p className="flex-none">{`${group.quantity} X ${group.cargoType.category}`}</p>
          </div>
        </div>

        <hr />
        <div className="flex-100 layout-row layout-wrap layout-align-start">
          <div
            className={`${
              styles.detailed_row
            } flex-100 layout-row layout-wrap layout-align-space-between-center`}
          >
            <div className=" flex-70 layout-row layout-wrap layout-align-start-center">
              <p className="flex-none">Cargo Type</p>
              <div className="flex-5" />
              <p className="flex-none">{group.cargoType.description}</p>
            </div>
            <div className="flex-30 layout-row layout-align-end-center">
              <p className="flex-none">Toggle Unit View</p>
              <div className="flex-5" />
              <Toggle
                className="flex-none"
                id="unitView"
                name="unitView"
                checked={unitView}
                onChange={e => this.handleViewToggle(e)}
              />
            </div>
          </div>
          <hr className="flex-100" />
        </div>
        <div className="flex-100 layout-row layout-align-none-start layout-wrap">
          {unitViewer}
          {aggViewer}
        </div>
        <hr className="flex-100" />
        {viewHSCodes ? (
          <div className="flex-100 layout-row layout-wrap" onClick={this.viewHsCodes}>
            <i className="fa fa-eye clip flex-none" style={textStyle} />
            <p className="offset-5 flex-none">View Hs Codes</p>
          </div>
        ) : (
          ''
        )}
        {viewer ? (
          <HsCodeViewer item={group} hsCodes={hsCodes} theme={theme} close={this.viewHsCodes} />
        ) : (
          ''
        )}
        {styleTagJSX}
      </div>
    )
  }
}
CargoItemGroup.propTypes = {
  group: PropTypes.objectOf(PropTypes.any).isRequired,
  viewHSCodes: PropTypes.bool,
  theme: PropTypes.theme,
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired
}

CargoItemGroup.defaultProps = {
  viewHSCodes: false,
  theme: false
}

export default CargoItemGroup

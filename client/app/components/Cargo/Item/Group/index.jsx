import React, { Component } from 'react'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import PropTypes from '../../../../prop-types'
import { HsCodeViewer } from '../../../HsCodes/HsCodeViewer'
import { gradientTextGenerator } from '../../../../helpers'
import CargoItemGroupAggregated from './Aggregated'
import { LOAD_TYPES } from '../../../../constants'

export class CargoItemGroup extends Component {
  constructor (props) {
    super(props)
    this.state = {
      viewer: false,
      unitView: false,
      collapsed: false
    }
    this.handleCollapser = this.handleCollapser.bind(this)
    this.viewHsCodes = this.viewHsCodes.bind(this)
  }
  viewHsCodes () {
    this.setState({
      viewer: !this.state.viewer
    })
  }
  handleCollapser () {
    this.setState({
      collapsed: !this.state.collapsed
    })
  }
  handleViewToggle (value) {
    this.setState({ unitView: !this.state.unitView })
  }
  render () {
    const {
      group, hsCodes, theme, viewHSCodes, shipment
    } = this.props
    const { viewer, unitView, collapsed } = this.state
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
    const unitArr = (
      <div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >
        <div className="flex-10 layout-row layout-align-center-center">
          <p className="flex-none" style={{ fontSize: '10px' }}>Single Item</p>
        </div>
        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img tooltip="Length" src="https://image.ibb.co/edttEd/Group_5_5.png" alt="Group_5_5" border="0" />
          <p className="flex-none"><span>{group.items[0].dimension_y}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img tooltip="Width" src="https://image.ibb.co/cdRkSy/Group_5_4.png" alt="Group_5_4" border="0" />
          <p className="flex-none"><span>{group.items[0].dimension_x}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} ${styles.side_border} flex-15 layout-row layout-align-center-center`}>
          <img tooltip="Height" src="https://image.ibb.co/f9QR0J/Group_5.png" alt="Group_5" border="0" />
          <p className="flex-none"><span>{group.items[0].dimension_z}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span>{group.items[0].payload_in_kg}</span> kg</p>
            <p className="flex-none layout-row layout-align-center-center">Gross Weight</p>
          </div>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {(group.items[0].dimension_y * group.items[0].dimension_x * group.items[0].dimension_y / 1000000).toFixed(2)}
              </span> m<sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">Volume</p>
          </div>
        </div>
        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span>{parseFloat(group.items[0].chargeable_weight).toFixed(2)}</span> kg</p>
            <p className="flex-none layout-row layout-align-center-center">Chargeable Weight</p>
          </div>
        </div>
        {/* <hr className="flex-100" /> */}
      </div>
    )
    // const unitStyle = unitView ? styles.open_panel : styles.closed_panel
    const aggStyle = unitView ? styles.closed_panel : styles.open_panel
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }
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
      <div className={`${styles.info}`}>
        <div className="flex-100 layout-row layout-align-center-center">
          <div className={`flex-5 layout-row layout-align-center-center ${styles.side_border}`}>
            <p className={`flex-none layout-row layout-align-center-center ${styles.cargo_unit}`}>{group.groupAlias}</p>
          </div>
          <div className={`flex-20 layout-row layout-align-center-center ${styles.side_border}`}>
            <p className="flex-none layout-row layout-align-center-center">{`x ${group.items.length}`}</p>
            {shipment.load_type === 'cargo_item' ? (
              <div className={styles.icon_cargo_item} style={imgLCL} />
            ) : (
              <div className={styles.icon_cargo_item} style={imgFCL} />
            )}
          </div>
          <div className={`flex-20 layout-row layout-align-center-center ${styles.side_border}`}>
            <div className="layout-column">
              <p className="flex-none layout-row layout-align-center-center"><span>{group.cargoType.category}</span></p>
              <p className="flex-none layout-row layout-align-center-center">Cargo type</p>
            </div>
          </div>
          <div className="flex-55 layout-row">
            {aggViewer}
          </div>
          <div
            className="flex-5 layout-row layout-align-center-center"
            onClick={this.handleCollapser}
            onChange={e => this.handleViewToggle(e)}
          >
            {/* <ToggleUnitRow
              collapsed
              content={unitViewer}
              handleCollapser={e => this.handleViewToggle(e)}
            /> */}
            <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down pointy`} />
          </div>
          {/* <div className="flex-5 layout-row">
            <Toggle
              className="flex-none"
              id="unitView"
              name="unitView"
              checked={unitView}
              onChange={e => this.handleViewToggle(e)}
            />
          </div> */}
        </div>

        <div className={`${styles.unit_viewer} ${collapsed ? '' : styles.closed_panel}`}>
          <div className="flex-100 layout-row layout-align-none-start layout-wrap">
            {unitArr}
          </div>
        </div>
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
  hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired,
  shipment: PropTypes.objectOf(PropTypes.any)
}

CargoItemGroup.defaultProps = {
  viewHSCodes: false,
  theme: false,
  shipment: {}
}

export default CargoItemGroup

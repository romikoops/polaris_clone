import React, { Component } from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import PropTypes from '../../../../prop-types'
// import { HsCodeViewer } from '../../../HsCodes/HsCodeViewer'
import CargoItemGroupAggregated from './Aggregated'
import { LOAD_TYPES, LOAD_SIZES, cargoGlossary } from '../../../../constants'
import { gradientTextGenerator } from '../../../../helpers'

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
      group, shipment, theme
    } = this.props
    const gradientTextStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const { unitView, collapsed } = this.state
    const showTooltip = true
    const tooltipId = v4()
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
          <img data-for={tooltipId} data-tip="Length" src={LOAD_SIZES.length} alt="Group_5_4" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none"><span>{group.items[0] ? group.items[0].dimension_x : ''}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img data-for={tooltipId} data-tip="Height" src={LOAD_SIZES.height} alt="Group_5" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none"><span>{group.items[0] ? group.items[0].dimension_z : ''}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} ${styles.side_border} flex-15 layout-row layout-align-center-center`}>
          <img data-for={tooltipId} data-tip="Width" src={LOAD_SIZES.width} alt="Group_5_5" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none"><span>{group.items[0] ? group.items[0].dimension_y : ''}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{group.items[0].payload_in_kg}</span>&nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">Gross Weight</p>
          </div>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {(group.items[0].dimension_y *
                group.items[0].dimension_x *
                group.items[0].dimension_z / 1000000).toFixed(2)}
              </span> &nbsp;m<sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">Volume</p>
          </div>
        </div>
        { !group.size_class ? <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span>{parseFloat(group.items[0].chargeable_weight).toFixed(2)}</span> &nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">Chargeable Weight</p>
          </div>
        </div> : '' }
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
    const cargoCategory = group.cargoType ? group.cargoType.category : cargoGlossary[group.size_class]
    return (
      <div className={`${styles.info}`}>
        <div className={`flex-100 layout-row layout-align-center-center ${styles.height_box} ${collapsed ? styles.height_box : styles.height_box}`}>
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
              <p className="flex-none layout-row layout-align-center-center"><span className={styles.cargo_type}>{cargoCategory}</span></p>
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
            <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down clip pointy`} style={gradientTextStyle} />
          </div>
        </div>

        <div className={`${styles.unit_viewer} ${collapsed ? '' : styles.closed_panel}`}>
          <div className="flex-100 layout-row layout-align-none-start layout-wrap">
            {unitArr}
          </div>
        </div>
        {/* {viewHSCodes ? (
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
        {styleTagJSX} */}
      </div>
    )
  }
}
CargoItemGroup.propTypes = {
  group: PropTypes.objectOf(PropTypes.any).isRequired,
  // viewHSCodes: PropTypes.bool,
  // hsCodes: PropTypes.arrayOf(PropTypes.string).isRequired,
  shipment: PropTypes.objectOf(PropTypes.any),
  theme: PropTypes.theme
}

CargoItemGroup.defaultProps = {
  // viewHSCodes: false,
  shipment: {},
  theme: null
}

export default CargoItemGroup

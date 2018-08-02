import React, { Component } from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import PropTypes from '../../../../prop-types'
import CargoItemGroupAggregated from './Aggregated'
import { LOAD_TYPES, LOAD_SIZES, cargoGlossary } from '../../../../constants'
import { gradientTextGenerator } from '../../../../helpers'
import {
  ALIGN_CENTER,
  ROW,
  WRAP_ROW,
  trim
} from '../../../../classNames'

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
      group,
      shipment,
      theme
    } = this.props
    const {
      unitView,
      collapsed
    } = this.state

    const gradientTextStyle = gradientTextStyleFn(theme)

    const showTooltip = true
    const tooltipId = v4()
    const Tooltip = () => {
      if (!showTooltip) {
        return ''
      }

      return (<ReactTooltip
        className={styles.tooltip}
        id={tooltipId}
        effect="solid"
      />)
    }

    const ChargeableWeight = () => {
      if (group.size_class) {
        return ''
      }
      const weight = parseFloat(group.items[0].chargeable_weight).toFixed(2)

      return (
        <div className={`${styles.unit_data_cell} ${ROW(15)} ${ALIGN_CENTER}`}>
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}><span>{weight}</span> &nbsp;kg</p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Chargeable Weight</p>
          </div>
        </div>
      )
    }

    const xDimension = group.items[0] ? group.items[0].dimension_x : ''
    const yDimension = group.items[0] ? group.items[0].dimension_y : ''
    const zDimension = group.items[0] ? group.items[0].dimension_z : ''
    const Volume = (group.items[0].dimension_y *
      group.items[0].dimension_x *
      group.items[0].dimension_z / 1000000).toFixed(2)

    const unitArr = (
      <div
        key={v4()}
        className={trim(`
          ${styles.detailed_row} 
          flex-100 
          layout-row 
          layout-wrap 
          layout-align-none-center
        `)}
      >
        <div className={`${ROW(10)} ${ALIGN_CENTER}`}>
          <p
            className="flex-none"
            style={{ fontSize: '10px' }}
          >
            Single Item
          </p>
        </div>

        <div className={trim(`
          ${styles.unit_data_cell} 
          ${ROW(15)}
          ${ALIGN_CENTER}
        `)}
        >
          <img
            data-for={tooltipId}
            data-tip="Length"
            src={LOAD_SIZES.length}
            alt="Group_5_4"
            border="0"
          />
          {Tooltip()}
          <p className="flex-none"><span>{xDimension}</span> cm</p>
        </div>

        <div className={trim(`
          ${styles.unit_data_cell} 
          ${ROW(15)}
          ${ALIGN_CENTER}
        `)}
        >
          <img
            data-for={tooltipId}
            data-tip="Height"
            src={LOAD_SIZES.height}
            alt="Group_5"
            border="0"
          />
          {Tooltip()}
          <p className="flex-none"><span>{zDimension}</span> cm</p>
        </div>

        <div className={`${styles.unit_data_cell} ${styles.side_border} flex-15 layout-row layout-align-center-center`}>
          <img
            data-for={tooltipId}
            data-tip="Width"
            src={LOAD_SIZES.width}
            alt="Group_5_5"
            border="0"
          />
          {Tooltip()}
          <p className="flex-none"><span>{yDimension}</span> cm</p>
        </div>

        <div className={trim(`
          ${styles.unit_data_cell}
          ${ROW(15)}
          ${ALIGN_CENTER} 
        `)}
        >
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span>{group.items[0].payload_in_kg}</span>&nbsp;kg</p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Gross Weight</p>
          </div>
        </div>

        <div className={trim(`
          ${styles.unit_data_cell} 
          ${ROW(15)}
          ${ALIGN_CENTER} 
        `)}
        >
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span>
                {Volume}
              </span> &nbsp;m<sup>3</sup>
            </p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Volume</p>
          </div>
        </div>
        { ChargeableWeight()}
      </div>
    )

    const aggStyle = unitView ? styles.closed_panel : styles.open_panel
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }

    const aggViewer = (
      <div className={trim(`
        ${aggStyle} 
        ${styles.panel} 
        ${WRAP_ROW(100)}
        layout-align-none-center
      `)}
      >
        <CargoItemGroupAggregated group={group} />
      </div>
    )
    const cargoCategory = group.cargoType ? group.cargoType.category : cargoGlossary[group.size_class]

    const Shipment = () => (shipment.load_type === 'cargo_item'
      ? <div className={styles.icon_cargo_item} style={imgLCL} />
      : <div className={styles.icon_cargo_item} style={imgFCL} />)

    return (
      <div className={styles.info}>
        <div className={trim(`
          ${ROW(100)} 
          ${ALIGN_CENTER} 
          ${styles.height_box} 
          ${collapsed ? styles.height_box : styles.height_box}
        `)}
        >
          <div className={`${ROW(5)} ${ALIGN_CENTER} ${styles.side_border}`}>
            <p className={trim(`
              ${ROW('none')} 
              ${ALIGN_CENTER} 
              ${styles.cargo_unit}
            `)}
            >
              {group.groupAlias}
            </p>
          </div>

          <div className={`${ROW(20)} ${ALIGN_CENTER} ${styles.side_border}`}>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>{`x ${group.items.length}`}</p>
            {Shipment()}
          </div>

          <div className={`${ROW(20)} ${ALIGN_CENTER} ${styles.side_border}`}>
            <div className="layout-column">
              <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
                <span className={styles.cargo_type}>{cargoCategory}</span>
              </p>
              <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Cargo type</p>
            </div>
          </div>

          <div className={ROW(55)}>{aggViewer}</div>

          <div
            onClick={this.handleCollapser}
            onChange={e => this.handleViewToggle(e)}
            className={`${ROW(5)} ${ALIGN_CENTER}`}
          >
            <i
              style={gradientTextStyle}
              className={trim(`
                ${collapsed ? styles.collapsed : ''} 
                fa 
                fa-chevron-down 
                clip 
                pointy
              `)}
            />
          </div>
        </div>

        <div className={trim(`
          ${styles.unit_viewer} 
          ${collapsed ? '' : styles.closed_panel}
        `)}
        >
          <div className={`${WRAP_ROW(100)} layout-align-none-start`}>
            {unitArr}
          </div>
        </div>
      </div>
    )
  }
}

function gradientTextStyleFn (theme) {
  if (theme && theme.colors) {
    return gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  }

  return { color: '#E0E0E0' }
}

CargoItemGroup.propTypes = {
  theme: PropTypes.theme,
  group: PropTypes.objectOf(PropTypes.any).isRequired,
  shipment: PropTypes.objectOf(PropTypes.any)
}

CargoItemGroup.defaultProps = {
  shipment: {},
  theme: null
}

export default CargoItemGroup

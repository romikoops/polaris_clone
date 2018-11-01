import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoContainerGroup.scss'
import PropTypes from '../../../../prop-types'
import CargoContainerGroupAggregated from './Aggregated'
import { LOAD_TYPES, cargoGlossary } from '../../../../constants'
import { gradientTextGenerator } from '../../../../helpers'

class CargoContainerGroup extends Component {
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
      group, shipment, theme, t
    } = this.props
    const gradientTextStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const { unitView, collapsed } = this.state
    const unitArr = (
      <div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >
        <div className="flex-10 layout-row layout-align-center-center">
          <p className="flex-none" style={{ fontSize: '10px' }}>{t('cargo:singleItem')}</p>
        </div>

        <div className={`${styles.unit_data_cell} flex layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{group.items[0].weight_class}</span>&nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:weightClass')}</p>
          </div>
        </div>
        <div className={`${styles.unit_data_cell} flex layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{group.items[0].payload_in_kg}</span>&nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:cargoGrossWeight')}</p>
          </div>
        </div>

        <div className={`${styles.unit_data_cell} flex layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {(group.items[0].gross_weight)}
              </span> &nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:grossWeight')}</p>
          </div>
        </div>
        <div className={`${styles.unit_data_cell} flex layout-row layout-align-center-center`}>
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span>{parseFloat(group.items[0].tare_weight)}</span> &nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:tareWeight')}</p>
          </div>
        </div>
      </div>
    )
    const aggStyle = unitView ? styles.closed_panel : styles.open_panel
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }
    const aggViewer = (
      <div
        className={`${aggStyle} ${
          styles.panel
        } flex-100 layout-row layout-wrap layout-align-none-center layout-wrap`}
      >
        <CargoContainerGroupAggregated group={group} />
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
              <p className="flex-none layout-row layout-align-center-center">{t('cargo:type')}</p>
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
      </div>
    )
  }
}
CargoContainerGroup.propTypes = {
  group: PropTypes.objectOf(PropTypes.any).isRequired,
  t: PropTypes.func.isRequired,
  shipment: PropTypes.objectOf(PropTypes.any),
  theme: PropTypes.theme
}

CargoContainerGroup.defaultProps = {
  shipment: {},
  theme: null
}

export default withNamespaces(['cargo', 'common'])(CargoContainerGroup)

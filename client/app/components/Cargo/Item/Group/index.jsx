import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import CargoItemGroupAggregated from './Aggregated'
import length from '../../../../assets/images/cargo/length.png'
import height from '../../../../assets/images/cargo/height.png'
import width from '../../../../assets/images/cargo/width.png'
import { LOAD_TYPES, cargoGlossary } from '../../../../constants'
import { gradientTextGenerator, numberSpacing, singleItemChargeableObject } from '../../../../helpers'

class CargoItemGroup extends Component {
  constructor (props) {
    super(props)
    this.state = {
      viewer: false,
      unitView: false,
      collapsed: true
    }
    this.handleCollapser = this.handleCollapser.bind(this)
    this.viewHsCodes = this.viewHsCodes.bind(this)
  }

  viewHsCodes () {
    this.setState((prevState) => {
      const { viewer } = prevState

      return { viewer: !viewer }
    })
  }

  handleCollapser () {
    this.setState((prevState) => {
      const { collapsed } = prevState

      return { collapsed: !collapsed }
    })
  }

  handleViewToggle () {
    this.setState((prevState) => {
      const { unitView } = prevState

      return { unitView: !unitView }
    })
  }

  render () {
    const {
      group, shipment, theme, t, hideUnits, scope
    } = this.props
    const gradientTextStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const { unitView, collapsed } = this.state
    const showTooltip = true
    const tooltipId = v4()
    const unitArr = [
      (<div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img data-for={tooltipId} data-tip={t('common:length')} src={length} alt="length" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none">
            <span>{group.items[0] ? group.items[0].dimension_x : ''}</span>
            {' '}
cm
          </p>

          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img data-for={tooltipId} data-tip={t('common:width')} src={width} alt="width" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none">
            <span>{group.items[0] ? group.items[0].dimension_y : ''}</span>
            {' '}
              cm
          </p>

          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <img data-for={tooltipId} data-tip={t('common:height')} src={height} alt="height" border="0" />
          {
            showTooltip
              ? <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
              : ''
          }
          <p className="flex-none">
            <span>{group.items[0] ? group.items[0].dimension_z : ''}</span>
            {' '}
              cm
          </p>

          <div className={`flex-none ${styles.operand}`}>=</div>
        </div>

       

        <div className={`${styles.unit_data_cell}  flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {numberSpacing((group.items[0].dimension_y *
                group.items[0].dimension_x *
                group.items[0].dimension_z / 1000000), 3)}
              </span>
              {' '}
&nbsp;m
              <sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:volume')}</p>
            <div className={`flex-none ${styles.operand}`}>x</div>
          </div>
        </div>
        <div className={`${styles.unit_data_cell}  flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {group.items[0].quantity}
              </span>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:quantity')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>=</div>
        </div>
        <div className={`${styles.unit_data_cell} ${styles.side_border} flex layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {numberSpacing(group.volume, 3)}
              </span>
              {' '}
&nbsp;m
              <sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalVolume')}</p>
          </div>

        </div>

      </div>
      ),
      (<div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >
        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{numberSpacing(group.items[0].payload_in_kg, 2)}</span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:itemGrossWeight')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell}  flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {group.items[0].quantity}
              </span>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:quantity')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>=</div>
        </div>
        <div className={`${styles.unit_data_cell} ${styles.side_border} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {numberSpacing(group.payload_in_kg, 2)}
              </span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalWeight')}</p>
          </div>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{numberSpacing((group.items[0].chargeable_weight), 2)}</span>
              {' '}
&nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:chargeableWeight')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell}  flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {group.items[0].quantity}
              </span>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:quantity')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>=</div>
        </div>
        <div className={`${styles.unit_data_cell} flex-20 layout-row layout-align-center-center`}>
          <div className="">
            <p
              className="flex-none layout-row layout-align-center-center"
              dangerouslySetInnerHTML={{ __html: chargeableData.value }}
            />
            <p className="flex-none layout-row layout-align-center-center">{chargeableData.title}</p>
          </div>
        </div>
      </div>
      )]
    const aggStyle = unitView ? styles.closed_panel : styles.open_panel
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const aggViewer = (
      <div
        className={`${aggStyle} ${
          styles.panel
        } flex-100 layout-row layout-wrap layout-align-none-center layout-wrap`}
      >
        <CargoItemGroupAggregated group={group} hideUnits={hideUnits} />
      </div>
    )
    const cargoCategory = group.cargoType ? group.cargoType.category : cargoGlossary[group.size_class]

    return (
      <div className={`${styles.info}`}>
      <div className={`flex-100 layout-row layout-align-start-center  ${styles.title_bar}`}>
        <div className={`flex-20 layout-row layout-align-center-center`}>
          <div className={styles.icon_cargo_item_small} style={imgLCL} />
          <p className="flex-none layout-row layout-align-center-center">{`${group.items.length} x ${group.cargoType.description}`}</p>
          
        </div>
      </div>
        <div className="flex-100 layout-row layout-align-end-start layout-wrap">
          {unitArr}
        </div>
        {/* <div className={`flex-100 layout-row layout-align-center-center ${styles.height_box} ${collapsed ? styles.height_box : styles.height_box}`}>
          <div className={`flex-5 layout-row layout-align-center-center ${styles.side_border}`}>
            <p className={`flex-none layout-row layout-align-center-center ${styles.cargo_unit}`}>{group.groupAlias}</p>
          </div>
          <div className={`flex-20 layout-row layout-align-center-center ${styles.side_border}`}>
            <p className="flex-none layout-row layout-align-center-center">{`x ${group.items.length}`}</p>
            <div className={styles.icon_cargo_item} style={imgLCL} />
          </div>
          <div className={`flex-20 layout-row layout-align-center-center ${styles.side_border}`}>
            <div className="">
              <p className="flex-none layout-row layout-align-center-center"><span className={styles.cargo_type}>{cargoCategory}</span></p>
              <p className="flex-none layout-row layout-align-center-center">{t('cargo:type')}</p>
            </div>
          </div>
          <div className="flex-55 layout-row">
            { aggViewer}
          </div>
          { hideUnits ? '' : (
            <div
              className="flex-5 layout-row layout-align-center-center"
              onClick={this.handleCollapser}
              onChange={e => this.handleViewToggle(e)}
            >
              <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down clip pointy`} style={gradientTextStyle} />
            </div>
          ) }
        </div>
        { hideUnits ? ''
          : (
            <div className={`${styles.unit_viewer} ${collapsed ? '' : styles.closed_panel}`}>
              <div className="flex-100 layout-row layout-align-none-start layout-wrap">
                {unitArr}
              </div>
            </div>
          ) } */}
      </div>
    )
  }
}

CargoItemGroup.defaultProps = {
  shipment: {},
  theme: null
}

export default withNamespaces(['cargo', 'common'])(CargoItemGroup)

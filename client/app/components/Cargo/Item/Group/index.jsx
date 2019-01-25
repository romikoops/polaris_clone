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
      group, shipment, theme, t, scope
    } = this.props
 
    const showTooltip = true
    const tooltipId = v4()
    const chargeableData = singleItemChargeableObject(group.items[0], shipment.mode_of_transport, t, scope)
    const unitArr = [
      (<div
        key={v4()}
        className={`${
          styles.detailed_row
        } flex-100 layout-row layout-wrap layout-align-none-center`}
      >

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <div className="layout-row">
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

            </div>
            <p className={`flex-none layout-row layout-align-center-center ${styles.dims}`}>{t('common:length')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <div className="layout-row">
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
            </div>
            <p className={`flex-none layout-row layout-align-center-center ${styles.dims}`}>{t('common:width')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>

        <div className={`${styles.unit_data_cell} flex-15 layout-row layout-align-center-center`}>
          <div className="">
            <div className="layout-row">
              <img data-for={tooltipId} data-tip={t('common:height')} src={height} alt="height" border="0" />
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
            </div>
            <p className={`flex-none layout-row layout-align-center-center ${styles.dims}`}>{t('common:height')}</p>
          </div>
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
        <div className={`${styles.unit_data_cell} flex-20 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{numberSpacing(group.items[0].payload_in_kg, 2)}</span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:itemGrossWeight')}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell}  flex-10 layout-row layout-align-center-center`}>
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
        <div className={`${styles.unit_data_cell} ${styles.side_border} flex-20 layout-row layout-align-center-center`}>
          <div className="">
            <p className="flex-none layout-row layout-align-center-center">
              <span>
                {numberSpacing(group.payload_in_kg, 2)}
              </span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalGrossWeight')}</p>
          </div>
        </div>

        <div className={`${styles.unit_data_cell} flex-20 layout-row layout-align-center-center`}>
          <div className="">
            <p
              className="flex-none layout-row layout-align-center-center"
              dangerouslySetInnerHTML={{ __html: chargeableData.value }}
            />
            <p className="flex-none layout-row layout-align-center-center">{chargeableData.title}</p>
          </div>
          <div className={`flex-none ${styles.operand}`}>x</div>
        </div>
        <div className={`${styles.unit_data_cell}  flex-10 layout-row layout-align-center-center`}>
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
              dangerouslySetInnerHTML={{ __html: chargeableData.total_value }}
            />
            <p className="flex-none layout-row layout-align-center-center">{chargeableData.total_title}</p>
          </div>
        </div>
      </div>
      )]
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }

    return (
      <div className={`${styles.info}`}>
        <div className={`flex-100 layout-row layout-align-start-center  ${styles.title_bar}`}>
          <div className="flex layout-row layout-align-start-center">
            <div className={styles.icon_cargo_item_small} style={imgLCL} />
            <p className="flex-none layout-row layout-align-center-center">{`${group.items.length} x ${group.cargoType.description}`}</p>

          </div>
        </div>
        <div className="flex-100 layout-row layout-align-end-start layout-wrap">
          {unitArr}
        </div>
      </div>
    )
  }
}

CargoItemGroup.defaultProps = {
  shipment: {},
  theme: null
}

export default withNamespaces(['cargo', 'common'])(CargoItemGroup)

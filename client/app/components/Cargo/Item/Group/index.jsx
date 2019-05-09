import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import '../../../../styles/react-toggle.scss'
import styles from './CargoItemGroup.scss'
import { LOAD_TYPES } from '../../../../constants'
import UnitsWeight from '../../../Units/Weight'
import { numberSpacing, singleItemChargeableObject } from '../../../../helpers'

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
      group, shipment, theme, t, scope, hideUnits
    } = this.props

    const chargeableData = singleItemChargeableObject(group.items[0], shipment.mode_of_transport, t, scope)
    const unitArr = [
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>
            {`${group.items[0].dimension_x}cm x ${group.items[0].dimension_y}cm x ${group.items[0].dimension_y}cm`}
          </p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <span>{ numberSpacing(group.volume / group.quantity, 3) }</span>
            &nbsp;m
            <sup>3</sup>
          </p>
        </td>
      </tr>),
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('common:quantity')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <span>{ group.quantity }</span>

          </p>
        </td>
      </tr>),
      (
        scope.cargo_overview_only ? ''
          : (
            <tr className={styles.data_table_row}>
              <td className={styles.table_title}>
                <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>
                  {t('common:grossWeightPerItem')}
                </p>
              </td>
              <td className={styles.table_value}>
                <p className="flex layout-row layout-align-end-center">
                  <UnitsWeight value={group.items[0].payload_in_kg} />
                </p>
              </td>
            </tr>
          )
      ),
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('cargo:totalVolume')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <span>{ numberSpacing(group.volume, 3) }</span>
            &nbsp;m
            <sup>3</sup>
          </p>
        </td>
      </tr>),
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('cargo:totalGrossWeight')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <UnitsWeight value={group.payload_in_kg} />
          </p>
        </td>
      </tr>),
      scope.hide_chargeable_weight_values ? ''
        : (
          <tr className={styles.data_table_row}>
            <td className={styles.table_title}>
              <p className="flex layout-row layout-align-start-center">{chargeableData.total_title}</p>
            </td>
            <td className={styles.table_value}>
              <p
                className="flex layout-row layout-align-end-center"
                dangerouslySetInnerHTML={{ __html: chargeableData.total_value }}
              />
            </td>
          </tr>
        )
    ]

    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }

    return (
      <div className={`${styles.info}`}>
        <div className={`flex-100 layout-row layout-align-start-center  ${styles.title_bar}`}>
          <div className="flex layout-row layout-align-start-center">
            <div className={styles.icon_cargo_item_small} style={imgLCL} />
            <p className="flex-none layout-row layout-align-center-center">
              {`${group.items.length} x ${get(group, ['cargoType', 'description'], '')}`}
            </p>

          </div>
        </div>
        <div className="flex-100 layout-row layout-align-end-start layout-wrap">
          <table className={`flex-100 ${styles.data_table}`}>
            <tbody>
              {unitArr}
            </tbody>
          </table>

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

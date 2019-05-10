import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import '../../../../styles/react-toggle.scss'
import styles from '../../Item/Group/CargoItemGroup.scss'
import UnitsWeight from '../../../Units/Weight'
import { LOAD_TYPES, cargoGlossary } from '../../../../constants'
import { gradientTextGenerator, numberSpacing } from '../../../../helpers'

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
    const unitArr = [
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

      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('cargo:totalPayloadWeight')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <UnitsWeight value={group.payload_in_kg} />
          </p>
        </td>
      </tr>),
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('cargo:totalTareWeight')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <UnitsWeight value={group.tare_weight} />
          </p>
        </td>
      </tr>),
      (<tr className={styles.data_table_row}>
        <td className={styles.table_title}>
          <p className={`flex layout-row layout-align-start-center ${styles.dims}`}>{t('cargo:totalGrossWeight')}</p>
        </td>
        <td className={styles.table_value}>
          <p className="flex layout-row layout-align-end-center">
            <UnitsWeight value={group.gross_weight} />
          </p>
        </td>
      </tr>)

    ]

    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }

    const cargoCategory = group.cargoType ? group.cargoType.category : cargoGlossary[group.size_class]

    return (
      <div className={`${styles.info}`}>
        <div className={`flex-100 layout-row layout-align-start-center  ${styles.title_bar}`}>
          <div className="flex layout-row layout-align-start-center">
            <div className={styles.icon_cargo_item_small} style={imgFCL} />
            <p className="flex-none layout-row layout-align-center-center">
              {`${group.quantity} x ${cargoCategory}`}
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

CargoContainerGroup.defaultProps = {
  shipment: {},
  theme: null
}

export default withNamespaces(['cargo', 'common'])(CargoContainerGroup)

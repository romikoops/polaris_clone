import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './ShipmentCargoItems.scss'
import defs from '../../styles/default_classes.scss'
import QuantityInput from '../QuantityInput/QuantityInput'
import '../../styles/select-css-custom.scss'
import getInputs from './inputs'

class ShipmentCargoItems extends Component {
  constructor (props) {
    super(props)
    this.state = {
      cargoItemTypes: [],
      cargoItemInfoExpanded: [true]
    }
    this.addNewCargo = this.addNewCargo.bind(this)
    this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this)
    this.handleCargoItemType = this.handleCargoItemType.bind(this)
  }

  componentWillMount () {
    const { cargoItems } = this.props
    const cargoItemTypes = cargoItems.map(cargoItem => (
      this.props.availableCargoItemTypes.find(cargoItemType => (
        +cargoItemType.key === +cargoItem.cargo_item_type_id
      ))
    ))
    const cargoItemInfoExpanded = cargoItems.map(() => true)
    this.setState({ cargoItemTypes, cargoItemInfoExpanded })
  }

  setFirstRenderInputs (bool) {
    this.setState({ firstRenderInputs: bool })
  }

  addNewCargo () {
    const { cargoItemInfoExpanded } = this.state
    cargoItemInfoExpanded.push(true)
    this.props.addCargoItem()
    this.setState({ firstRenderInputs: true, cargoItemInfoExpanded })
  }

  handleCargoItemType (event) {
    const index = event.name.split('-')[0]
    const modifiedEvent = {
      target: { name: `${index}-cargo_item_type_id`, value: event.key }
    }
    const newCargoItemTypes = this.state.cargoItemTypes
    newCargoItemTypes[index] = event
    this.setState({ cargoItemTypes: newCargoItemTypes })
    this.props.handleDelta(modifiedEvent, !event.key)

    if (!event.dimension_x) return

    const modifiedEventDimentionX = {
      target: { name: `${index}-dimension_x`, value: event.dimension_x }
    }
    const modifiedEventDimentionY = {
      target: { name: `${index}-dimension_y`, value: event.dimension_y }
    }
    this.props.handleDelta(modifiedEventDimentionX)
    this.props.handleDelta(modifiedEventDimentionY)
  }

  toggleCheckbox (value, e) {
    const artificialEvent = {
      target: { name: e.target.name, value }
    }
    this.props.handleDelta(artificialEvent)
  }

  toggleCargoItemInfoExpanded (i) {
    const { cargoItemInfoExpanded } = this.state
    cargoItemInfoExpanded[i] = !cargoItemInfoExpanded[i]
    this.setState({ cargoItemInfoExpanded })
  }

  deleteCargo (index) {
    const { cargoItemTypes } = this.state
    cargoItemTypes.splice(index, 1)
    this.setState({ cargoItemTypes })

    this.props.deleteItem('cargoItems', index)
  }

  render () {
    const {
      cargoItems,
      theme,
      toggleModal,
      nextStageAttempt,
      scope,
      handleDelta,
      maxDimensions,
      availableCargoItemTypes,
      availableMotsForRoute,
      t
    } = this.props
    const { cargoItemTypes, firstRenderInputs, cargoItemInfoExpanded } = this.state
    const cargosAdded = []
    const numberOptions = []
    for (let i = 1; i <= 20; i++) {
      numberOptions.push({ label: i, value: i })
    }
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const generateCargoItem = (cargoItem, i) => {
      const inputs = getInputs.call(
        this,
        cargoItem,
        i,
        theme,
        cargoItemTypes,
        availableCargoItemTypes,
        numberOptions,
        firstRenderInputs,
        toggleModal,
        nextStageAttempt,
        scope,
        maxDimensions,
        availableMotsForRoute,
        t
      )

      return (
        <div
          key={i}
          name={`${i}-cargoItem`}
          className="layout-row flex-100 layout-wrap layout-align-stretch"
          style={{ position: 'relative', margin: '30px 0' }}
        >
          <div className={`flex-100 layout-align-start-center layout-row ${styles.cargo_unit_header}`}>
            <h3>{t('cargo:yourCargo')}</h3>
            {cargoItem ? (
              <div className={styles.delete_icon} onClick={() => this.deleteCargo(i)}>
                {t('common:delete')}
                <i className="fa fa-trash" />
              </div>
            ) : (
              ''
            )}
          </div>
          <div className={`flex-100 layout-row layout-wrap ${styles.cargo_unit_inputs}`}>
            <div className="flex-15 layout-row layout-align-center">
              <QuantityInput
                i={i}
                cargoItem={cargoItem}
                handleDelta={handleDelta}
                nextStageAttempt={nextStageAttempt}
              />
            </div>
            <div className={`${styles.cargo_item_box} ${styles.cargo_item_inputs} flex-85`}>
              <div style={{ position: 'relative' }}>
                <div
                  className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
                  style={{ marginBottom: '20px' }}
                >
                  {inputs.length}
                  {inputs.width}
                  {inputs.height}
                  <div className="flex-5" />
                  {scope.frontend_consolidation ? inputs.collectiveWeight : inputs.grossWeight}
                </div>
                <div className="flex-100 layout-row" />
                <div
                  className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
                  style={{ margin: '20px 0' }}
                >
                  {inputs.colliType}
                  {inputs.nonStackable}
                  {inputs.dangerousGoods}
                </div>
              </div>
              <div
                className={
                  `${styles.cargo_item_info} ` +
              `${cargoItemInfoExpanded[i] && styles.expanded} ` +
              'flex-100'
                }
              >
                <div
                  className={
                    `${styles.inner_cargo_item_info} layout-row flex-100 layout-wrap layout-align-start`
                  }
                >
                  <div className="flex-25 layout-wrap layout-row">
                    {inputs.totalVolume}
                    {inputs.chargeableVolume}
                  </div>
                  <div className={`${styles.padding_left} flex-25 layout-wrap layout-row`}>
                    {inputs.totalWeight}
                    {inputs.chargeableWeight}
                  </div>
                </div>
              </div>

            </div>

          </div>

        </div>
      )
    }

    if (cargoItems) {
      cargoItems.forEach((cargoItem, i) => {
        cargosAdded.push(generateCargoItem(cargoItem, i))
      })
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-center">
        <div
          className={
            `layout-row flex-none layout-wrap layout-align-center-center ${defs.content_width} `
          }
        >
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {cargosAdded}
          </div>

          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className={`${styles.add_unit_wrapper} content_width`}>
              <div
                className={
                  `layout-row flex-none ${styles.add_unit} ` +
                  'layout-wrap layout-align-center-center'
                }
                onClick={this.addNewCargo}
              >
                <i className="fa fa-plus-square-o clip" style={textStyle} />
                <p> {t('shipment:addUnit')}</p>
              </div>
            </div>
          </div>
        </div>
        <style>
          {`
            .colli_type .Select-control {
              display: flex;
              position: relative;
              border: 1px solid #E0E0E0;
              box-shadow: none;
              background: transparent;
            }
            .colli_type .Select {
              box-shadow: none;
            }
            .colli_type .Select-value {
              background: transparent;
              box-shadow: none;
              border: 1px solid #E0E0E0;
            }
            .colli_type .Select-placeholder {
              background: transparent;
              box-shadow: none;
              padding-bottom: 5px;
              border: 1px solid #E0E0E0;
            }
            .colli_type .Select-clear-zone {
              position: absolute;
              right: 25px;
              top: 6px;
            }
            .colli_type .Select-arrow-zone {
              position: absolute;
              right: 0;
              top: 10px;
            }
          `}
        </style>
      </div>
    )
  }
}

ShipmentCargoItems.defaultProps = {
  theme: null,
  toggleModal: null,
  nextStageAttempt: false,
  cargoItems: [],
  availableCargoItemTypes: [],
  availableMotsForRoute: []
}

export default withNamespaces(['shipment', 'common', 'cargo', 'errors'])(ShipmentCargoItems)

import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './ShipmentCargoItems.scss'
import defs from '../../styles/default_classes.scss'
import QuantityInput from '../QuantityInput/QuantityInput'
import '../../styles/select-css-custom.css'
import getInputs from './inputs'

export class ShipmentCargoItems extends Component {
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
      maxDimensions
    } = this.props
    const { cargoItemTypes, firstRenderInputs, cargoItemInfoExpanded } = this.state
    const cargosAdded = []
    const availableCargoItemTypes = this.props.availableCargoItemTypes
      ? this.props.availableCargoItemTypes.map(cargoItemType => ({
        label: cargoItemType.description,
        key: cargoItemType.id,
        dimension_x: cargoItemType.dimension_x,
        dimension_y: cargoItemType.dimension_y
      }))
      : []
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
        maxDimensions
      )

      return (
        <div
          key={i}
          name={`${i}-cargoItem`}
          className="layout-row flex-100 layout-wrap layout-align-stretch"
          style={{ position: 'relative', margin: '30px 0' }}
        >
          <div className="flex-10 layout-row layout-align-center">
            <QuantityInput
              i={i}
              cargoItem={cargoItem}
              handleDelta={handleDelta}
              nextStageAttempt={nextStageAttempt}
            />
          </div>
          <div className={`${styles.cargo_item_box} ${styles.cargo_item_inputs} flex-90`}>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              {inputs.colliType}
              {inputs.nonStackable}
              {inputs.dangerousGoods}
            </div>
            <div
              className="layout-row flex-100 layout-wrap layout-align-start-center"
              style={{ marginTop: '20px' }}
            >
              {inputs.length}
              {inputs.width}
              {inputs.height}
              <div className="flex-10" />
              {inputs.grossWeight}
            </div>
            <div className={styles.expandIcon} onClick={() => this.toggleCargoItemInfoExpanded(i)}>
              Aditional Details
              <i className={`${cargoItemInfoExpanded[i] && styles.rotated} fa fa-chevron-right`} />
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
                `${styles.inner_cargo_item_info} layout-row layout-wrap layout-align-start`
              }
            >
              {inputs.total}
              <div className={`${styles.cargo_item_box} flex layout-row`}>
                {inputs.volume}
                {inputs.chargeableWeight}
              </div>
            </div>
          </div>

          {cargoItem ? (
            <div className={styles.delete_icon} onClick={() => this.deleteCargo(i)}>
              Delete
              <i className="fa fa-trash" />
            </div>
          ) : (
            ''
          )}
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
                <p> Add Unit</p>
              </div>
            </div>
            <div className={`flex-100 ${styles.new_container_placeholder}`}>
              {generateCargoItem(null, -1)}
            </div>
          </div>
        </div>
        <style>
          {`            
            .colli_type .Select-control {
              display: flex;
              height: 32px;
              position: relative;
            }
            .colli_type .Select-clear-zone {
              position: absolute;
              right: 25px;
              top: 6px;           
            }
            .colli_type .Select-arrow-zone {
              position: absolute;
              right: 0;
              top: 5px;
            }
          `}
        </style>
      </div>
    )
  }
}

ShipmentCargoItems.propTypes = {
  theme: PropTypes.theme,
  deleteItem: PropTypes.func.isRequired,
  cargoItems: PropTypes.arrayOf(PropTypes.shape({
    description: PropTypes.text,
    key: PropTypes.number,
    dimension_x: PropTypes.number,
    dimension_y: PropTypes.number,
    dangerous_goods: PropTypes.bool,
    stackable: PropTypes.bool
  })),
  availableCargoItemTypes: PropTypes.arrayOf(PropTypes.shape({
    description: PropTypes.text,
    key: PropTypes.number,
    dimension_x: PropTypes.number,
    dimension_y: PropTypes.number
  })),
  addCargoItem: PropTypes.func.isRequired,
  handleDelta: PropTypes.func.isRequired,
  toggleModal: PropTypes.func,
  nextStageAttempt: PropTypes.bool,
  scope: PropTypes.shape({
    dangerous_goods: PropTypes.bool
  }).isRequired,
  maxDimensions: PropTypes.objectOf(PropTypes.number).isRequired
}

ShipmentCargoItems.defaultProps = {
  theme: null,
  toggleModal: null,
  nextStageAttempt: false,
  cargoItems: [],
  availableCargoItemTypes: []
}

export default ShipmentCargoItems

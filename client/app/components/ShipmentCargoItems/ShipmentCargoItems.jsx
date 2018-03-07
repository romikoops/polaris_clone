import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './ShipmentCargoItems.scss'
import defs from '../../styles/default_classes.scss'
import QuantityInput from '../QuantityInput/QuantityInput'
import { TextHeading } from '../TextHeading/TextHeading'
import '../../styles/select-css-custom.css'
import getInputs from './inputs'

export class ShipmentCargoItems extends Component {
  constructor (props) {
    super(props)
    this.state = {
      cargoItemTypes: [],
      cargoItemInfoExpanded: []
    }
    this.handleCargoChange = this.handleCargoChange.bind(this)
    this.addNewCargo = this.addNewCargo.bind(this)
    this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this)
    this.handleCargoItemType = this.handleCargoItemType.bind(this)
  }

  setFirstRenderInputs (bool) {
    this.setState({ firstRenderInputs: bool })
  }

  handleCargoChange (event) {
    const { name, value } = event.target
    this.setState({
      newCargoItem: { ...this.state.newCargoItem, [name]: value }
    })
  }

  addNewCargo () {
    this.props.addCargoItem()
    this.setState({ firstRenderInputs: true })
  }
  handleCargoItemType (event) {
    const index = event.name.split('-')[0]
    const modifiedEvent = {
      target: { name: `${index}-cargo_item_type_id`, value: event.key }
    }
    const newCargoItemTypes = this.state.cargoItemTypes
    newCargoItemTypes[index] = event
    this.setState({ cargoItemTypes: newCargoItemTypes })
    this.props.handleDelta(modifiedEvent)

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
      cargoItems, theme, showAlertModal, nextStageAttempt, scope, handleDelta
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

    // const generateSeparator = () => (
    //   <div key={v4()} className={`${styles.separator} flex-100`}>
    //     <hr />
    //   </div>
    // )
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
        showAlertModal,
        nextStageAttempt,
        scope
      )

      return (
        <div
          key={i}
          className="layout-row flex-100 layout-wrap layout-align-stretch"
          style={{ position: 'relative', margin: '30px 0' }}
        >
          <div className="flex-15 layout-row layout-align-center">
            <QuantityInput
              i={i}
              cargoItem={cargoItem}
              handleDelta={handleDelta}
              firstRenderInputs={firstRenderInputs}
              nextStageAttempt={nextStageAttempt}
            />
          </div>
          <div className={`${styles.cargo_item_box} ${styles.cargo_item_inputs} flex-85`}>
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
          <div className={
            `${styles.cargo_item_box} ${styles.cargo_item_info} ` +
            `${cargoItemInfoExpanded[i] && styles.expanded} ` +
            'flex-85 offset-15'
          }
          >
            <div className={
              `${styles.inner_cargo_item_info} layout-row ` +
              'layout-wrap layout-align-start'
            }
            >
              {inputs.volume}
              {inputs.chargeableWeight}
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
        // if (!cargoItemTypes[i]) {
        //   // Set a default cargo item type as the select box value

        //   // Define labels of the default cargo item types in order of priority
        //   const defaultTypeLabels = ['Pallet', '100.0cm × 120.0cm Pallet: Europe, Asia']

        //   // Try to find one of the labels in the available cargo item types
        //   let defaultType
        //   defaultTypeLabels.find(defaultTypeLabel => (
        //     defaultType = availableCargoItemTypes.find(cargoItemType => (
        //       cargoItemType.label === defaultTypeLabel
        //     ))
        //   ))

        //   // In case none of the defaultTypeLabels match the available
        //   // cargo item types, set the default to the first available.
        //   defaultType = defaultType || availableCargoItemTypes[0]

        //   this.handleCargoItemType(Object.assign({ name: `${i}-colliType` }, defaultType))
        // }
        cargosAdded.push(generateCargoItem(cargoItem, i))
        // cargosAdded.push(generateSeparator())
      })
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-center">
        <div
          className={`layout-row flex-none ${
            defs.content_width
          } layout-wrap layout-align-center-center section_padding`}
          style={{ margin: '0 0 70px 0' }}
        >
          <TextHeading theme={theme} text="Cargo Units" size={3} />
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {cargosAdded}
          </div>

          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className={`${styles.add_unit_wrapper} content_width`}>
              <div
                className={`layout-row flex-none ${
                  styles.add_unit
                } layout-wrap layout-align-center-center`}
                onClick={this.addNewCargo}
              >
                <i className="fa fa-plus-square-o clip" style={textStyle} />
                <p> Add unit</p>
              </div>
            </div>
            <div className={`flex-100 ${styles.new_container_placeholder}`}>
              { generateCargoItem(null, -1) }
            </div>
          </div>
        </div>
        <style>
          {`
            .Select-control {
              display: flex;
              height: 32px;
              position: relative;
            }
            .Select-arrow-zone {
              position: absolute;
              right: 0;
              top: 5px
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
  showAlertModal: PropTypes.func,
  nextStageAttempt: PropTypes.bool,
  scope: PropTypes.shape({
    dangerous_goods: PropTypes.bool
  }).isRequired
}

ShipmentCargoItems.defaultProps = {
  theme: null,
  showAlertModal: null,
  nextStageAttempt: false,
  cargoItems: [],
  availableCargoItemTypes: []
}

export default ShipmentCargoItems

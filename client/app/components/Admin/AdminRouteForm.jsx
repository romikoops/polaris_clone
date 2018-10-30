import React, { Component } from 'react'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import '../../styles/select-css-custom.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { moTOptions } from '../../constants'

export class AdminRouteForm extends Component {
  constructor (props) {
    super(props)
    this.state = {
      location: {},
      route: {
        name: '',
        stops: [{ id: null, value: null }, { id: null, value: null }]
      },
      selectValues: [{ id: null, value: null }, { id: null, value: null }]
    }
    this.handleNameChange = this.handleNameChange.bind(this)
    this.handleHubChange = this.handleHubChange.bind(this)
    this.saveNewRoute = this.saveNewRoute.bind(this)
    this.excludeHubs = this.excludeHubs.bind(this)
    this.handleMotChange = this.handleMotChange.bind(this)
    this.addStop = this.addStop.bind(this)
  }

  handleNameChange (event) {
    const { value } = event
    this.setState({
      ...this.state,
      route: {
        ...this.state.route,
        name: value
      }
    })
  }
  handleMotChange (event) {
    this.setState({
      route: {
        ...this.state.route,
        mot: event.value.split('_')[0]
      },
      selectValues: {
        ...this.state.selectValues,
        mot: event
      }
    })
  }
  handleHubChange (event) {
    const { value, name, label } = event
    const { selectValues, route } = this.state
    const { stops } = route
    let inputName

    if (name === stops.length - 1) {
      inputName = `${selectValues[0].label} - ${label}`
    }

    stops[name] = value
    selectValues[name] = event
    this.setState({
      ...this.state,
      route: {
        ...route,
        stops,
        name: inputName
      },
      selectValues
    })
  }
  addStop () {
    const { stops } = this.state.route
    stops.push({ id: null, name: null })
    this.setState({
      route: {
        ...this.state.route,
        stops
      }
    })
  }

  saveNewRoute () {
    const { route } = this.state
    this.props.saveRoute(route)
    this.props.close()
  }
  excludeHubs (hubs) {
    const { route } = this.state
    const filteredHubs = hubs.filter(x => route.stops.indexOf(x.id) < 0)
    let results
    switch (route.mot) {
      case 'air':
        results = filteredHubs.filter(h => h.data.name.includes('Airport'))
        break
      case 'ocean':
        results = filteredHubs.filter(h => h.data.name.includes('Port'))
        break
      case 'rail':
        results = filteredHubs.filter(h => h.data.name.includes('Depot'))
        break
      case false || undefined:
        results = filteredHubs
        break
      default:
        results = filteredHubs
        break
    }

    return results.map(h => ({ label: h.data.name, value: h.data.id }))
  }

  render () {
    const { theme, hubs } = this.props
    const { route, selectValues } = this.state
    const filteredHubs = hubs ? this.excludeHubs(hubs) : []
    const StyledSelect = styled(NamedSelect)`
      width: 100%;
      .Select-control {
        background-color: #f9f9f9;
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
      }
    `
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const hubInputs = route.stops.map((st, i) => (
      <div
        className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_row}`}
      >
        <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
          <p className="flex-none">Stop {i}</p>
        </div>
        <div className="flex-100 flex-gt-sm-50 layout-align-end-center">
          <StyledSelect
            placeholder="Origin"
            className={styles.select}
            name={i}
            value={selectValues[i]}
            options={filteredHubs}
            onChange={this.handleHubChange}
          />
        </div>
      </div>
    ))

    return (

      <div
        className={`${styles.route_form} layout-row flex-none layout-wrap layout-align-center`}
      >
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-start ${
            styles.form_padding
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <h2 className="flex-none clip letter_3" style={textStyle}>
                Add a New Route
            </h2>
          </div>
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-center ${
              styles.form_row
            }`}
          >
            <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
              <p className="flex-none">Mode of Transport</p>
            </div>
            <div className="flex-100 flex-gt-sm-50 layout-align-end-center">
              <StyledSelect
                placeholder="Mode of Transport"
                className={styles.select}
                name="mot"
                value={selectValues.mot}
                options={moTOptions}
                onChange={this.handleMotChange}
              />
            </div>
          </div>
          {hubInputs}
          <div className="flex-100 layout-align-end-center layout-row">
            <div
              className="flex-none layout-row layout-align-cetner-center"
              onClick={this.addStop}
            >
              <i className="fa fa-plus-cicle-o" />
              <p className="flex-none no_m">Add Stop</p>
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-center ${
              styles.form_row
            }`}
          >
            <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
              <p className="flex-none">Name</p>
            </div>
            <div className="flex-100 flex-gt-sm-50 layout-align-end-center input_box_full">
              <input
                type="text"
                value={route.name}
                onChange={this.handleNameChange}
                name="name"
              />
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-end-center">
          <RoundButton
            className="flex-none"
            theme={theme}
            size="small"
            text="Save Route"
            active
            handleNext={this.saveNewRoute}
            iconClass="fa-floppy"
          />
          <div className="flex-5" />
        </div>
      </div>
    )
  }
}

AdminRouteForm.propTypes = {
  theme: PropTypes.theme,
  saveRoute: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.hub)
}

AdminRouteForm.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminRouteForm

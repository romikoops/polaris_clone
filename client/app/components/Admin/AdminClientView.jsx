import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { AdminShipmentRow, AdminAddressTile } from './'
import styles from './Admin.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { gradientTextGenerator } from '../../helpers'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { managerRoles } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminClientView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedManager: {},
      selectedRole: {},
      showAddManager: false
    }
    this.handleManagerAssigment = this.handleManagerAssigment.bind(this)
    this.handleRoleAssigment = this.handleRoleAssigment.bind(this)
    this.toggleNewManager = this.toggleNewManager.bind(this)
    this.assignNewManager = this.assignNewManager.bind(this)
  }
  handleManagerAssigment (event) {
    this.setState({ selectedManager: event })
  }
  handleRoleAssigment (event) {
    this.setState({ selectedRole: event })
  }
  toggleNewManager () {
    this.setState({ showAddManager: !this.state.showAddManager })
  }
  assignNewManager () {
    const { adminDispatch, clientData } = this.props
    const { client } = clientData
    const { selectedRole, selectedManager } = this.state
    adminDispatch.assignManager({
      manager_id: selectedManager.value,
      role: selectedRole.value,
      client_id: client.id
    })
    this.toggleNewManager()
  }
  render () {
    const {
      theme, clientData, hubs, managers
    } = this.props
    if (!clientData) {
      return ''
    }

    const { selectedManager, selectedRole, showAddManager } = this.state
    const {
      client, shipments, locations, managerAssignments
    } = clientData
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const shipRows = []
    const managerOpts = managers.map(m => ({
      label: `${m.first_name} ${m.last_name}`,
      value: m.id
    }))
    console.log(managerOpts)
    const relManagers = managerAssignments
      ? managerAssignments.map((ma) => {
        const man = managers.filter(m => m.id === ma.manager_id)[0]
        man.section = ma.section
        return man
      })
      : []
    console.log(managerAssignments)
    const manArray = relManagers
      ? relManagers.map(ma => (
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-50 layout-row layout-align-start-center">
            <i className="fa fa-user flex-none clip" style={textStyle} />
            <p className="flex-none">{`${ma.first_name} ${ma.last_name}`}</p>
          </div>
          <div className="flex-50 layout-row layout-align-start-center">
            <i className="fa fa-book flex-none clip" style={textStyle} />
            <p className="flex-none">{`Section: ${ma.section}`}</p>
          </div>
        </div>
      ))
      : []
    console.log(relManagers)
    shipments.forEach((ship) => {
      shipRows.push(<AdminShipmentRow
        key={v4()}
        shipment={ship}
        hubs={hubs}
        theme={theme}
        handleSelect={this.viewShipment}
        client={client}
      />)
    })
    const locationArr = locations.map(loc => (
      <AdminAddressTile key={v4()} address={loc} theme={theme} client={client} />
    ))
    const assignManagerBox = (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <NamedSelect
            name="manager"
            placeholder="Choose manager"
            classes={`${styles.select}`}
            value={selectedManager}
            options={managerOpts}
            className="flex-100"
            onChange={this.handleManagerAssigment}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <NamedSelect
            name="manager"
            placeholder="Choose area"
            classes={`${styles.select}`}
            value={selectedRole}
            options={managerRoles}
            className="flex-100"
            onChange={this.handleRoleAssigment}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <div className="flex-none layout-row">
            <RoundButton
              theme={theme}
              size="small"
              text="Save"
              handleNext={this.assignNewManager}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )
    const managerBox = (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div className="flex-80 layout-row">
            <RoundButton
              theme={theme}
              size="full"
              text="Assign Manager"
              handleNext={this.toggleNewManager}
              iconClass="fa-plus"
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none">Account Managers</p>
          </div>
          {manArray}
        </div>
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap layout-align-start-start layout-wrap">
          <div
            className={`flex-100 layout-row layout-align-space-between-center  ${styles.sec_title}`}
          >
            <TextHeading theme={theme} size={1} text="Client Overview" />
            <div className="flex-40 layout-row layout-align-space-around-center">
              <h2 className="flex-none"> {client.first_name} </h2>
              <h2 className="flex-none"> {client.last_name} </h2>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-start layout-wrap padd_20">
            <div className="flex-65 layout-row layout-align-start-start layout-wrap">
              <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                  <sup style={textStyle} className="clip flex-none">
                    Company
                  </sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                  <p className="flex-none"> {client.company_name}</p>
                </div>
              </div>

              <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                  <sup style={textStyle} className="clip flex-none">
                    Email
                  </sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                  <p className="flex-none"> {client.email}</p>
                </div>
              </div>
              <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                  <sup style={textStyle} className="clip flex-none">
                    Phone
                  </sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                  <p className="flex-none"> {client.phone}</p>
                </div>
              </div>
            </div>
            <div className="flex-35 layout-row layout-align-start-start layout-wrap">
              {showAddManager ? assignManagerBox : managerBox}
            </div>
          </div>
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <TextHeading theme={theme} size={2} text="Shipments" />
          </div>
          {shipRows}
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <TextHeading theme={theme} size={2} text="Locations" />
          </div>
          {locationArr}
        </div>
      </div>
    )
  }
}
AdminClientView.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  clientData: PropTypes.shape({
    client: PropTypes.client,
    shipments: PropTypes.shipments,
    locations: PropTypes.arrayOf(PropTypes.location)
  })
}

AdminClientView.defaultProps = {
  theme: null,
  hubs: [],
  clientData: null
}

export default AdminClientView

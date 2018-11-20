import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminChargeSection } from './'
// import { v4 } from 'uuid';
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminChargePanel extends Component {
  constructor (props) {
    super(props)
    this.handleLink = this.handleLink.bind(this)
    this.state = {
      editCharge: false,
      tmpObj: props.charge ? props.charge : {}
    }
    this.toggleExpand = this.toggleExpand.bind(this)
    this.toggleEdit = this.toggleEdit.bind(this)
    this.handleEdit = this.handleEdit.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.setCurrency = this.setCurrency.bind(this)
  }
  setCurrency (val, tag) {
    this.setState({
      tmpObj: {
        ...this.state.tmpObj,
        [tag]: {
          ...this.state.tmpObj[tag],
          currency: val.value
        }
      }
    })
  }
  handleLink () {
    const { target, navFn } = this.props
    navFn(target)
  }
  toggleExpand () {
    this.props.backFn()
  }
  toggleEdit () {
    const { editCharge } = this.state
    const { charge } = this.props
    if (!editCharge) {
      this.setState({
        editCharge: true,
        tmpObj: charge
      })
    } else {
      this.setState({
        editCharge: false,
        tmpObj: {}
      })
    }
  }
  handleEdit (ev) {
    const { name, value } = ev.target
    this.setState({
      tmpObj: {
        ...this.state.tmpObj,
        [name]: {
          ...this.state.tmpObj[name],
          value: parseInt(value, 10)
        }
      }
    })
  }
  saveEdit () {
    const { tmpObj } = this.state
    const { charge, adminTools } = this.props
    delete tmpObj.id
    delete tmpObj.hub_id
    delete tmpObj.created_at
    delete tmpObj.updated_at
    adminTools.updateServiceCharge(charge.id, tmpObj)
    this.toggleExpand()
  }

  render () {
    const { editCharge, tmpObj } = this.state
    const { theme, hub, charge } = this.props
    if (!hub || !charge) {
      return ''
    }

    const gradientStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})`
          : 'black'
    }
    const saveButton = (
      <div className="flex-100 layout-row layout-align-end-start layout-wrap button_padding">
        <div className="flex-none layout-row">
          <RoundButton
            theme={theme}
            size="small"
            text="Save"
            active
            handleNext={this.saveEdit}
            iconClass="fa-floppy-o"
          />
        </div>
      </div>
    )

    const exportArr = []
    const importArr = []

    Object.keys(charge).forEach((key) => {
      if (charge[key] && charge[key].trade_direction && charge[key].trade_direction === 'import') {
        importArr.push(<AdminChargeSection
          key={key}
          tag={key}
          value={charge[key].value}
          editCharge={editCharge}
          currency={charge[key].currency}
          editCurr={{ value: tmpObj[key].currency, label: tmpObj[key].currency }}
          editVal={tmpObj[key].value}
          handleEdit={this.handleEdit}
          setCurrency={this.setCurrency}
        />)
      } else if (
        charge[key] &&
        charge[key].trade_direction &&
        charge[key].trade_direction === 'export'
      ) {
        exportArr.push(<AdminChargeSection
          key={key}
          tag={key}
          value={charge[key].value}
          editCharge={editCharge}
          currency={charge[key].currency}
          editCurr={{ value: tmpObj[key].currency, label: tmpObj[key].currency }}
          editVal={tmpObj[key].value}
          handleEdit={this.handleEdit}
          setCurrency={this.setCurrency}
        />)
      }
    })
    return (
      <div className={`flex-100 ${styles.charge_card} layout-row layout-wrap`}>
        <div className={`${styles.charge_header} layout-row layout-wrap flex-100`}>
          <div className="flex-100 layout-row">
            <div className="flex-5 layout-column layout-align-center-center">
              <i className="flex-none fa fa-map-marker clip" style={gradientStyle} />
            </div>
            <div className="flex-80 layout-row layout-wrap layout-align-start-start">
              <h3 className="flex-100 clip" style={gradientStyle}>
                {' '}
                {hub.name}{' '}
              </h3>
            </div>
            <div className="flex-15 layout-row layout-align-end-center">
              <div className="flex layout-row layout-align-center-center" onClick={this.toggleEdit}>
                <i className="flex-none fa fa-pencil clip" style={gradientStyle} />
              </div>
              <div
                className="flex layout-row layout-align-center-center"
                onClick={this.toggleExpand}
              >
                <p className="flex-none clip" style={gradientStyle}>
                  Back
                </p>
              </div>
            </div>
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-space-around-start ${
            styles.charge_panel
          }`}
        >
          <div
            className={`flex-80 layout-row layout-wrap layout-align-start-start ${
              styles.charge_panel_xxport
            }`}
          >
            <div className="flex-100 layout-row layout-align-start-start">
              <h3 className="flex-none">Import</h3>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
              {importArr}
            </div>
          </div>
          <div
            className={`flex-80 layout-row layout-wrap layout-align-start-start ${
              styles.charge_panel_xxport
            }`}
          >
            <div className="flex-100 layout-row layout-align-start-start">
              <h3 className="flex-none">Export</h3>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
              {exportArr}
            </div>
          </div>
          {editCharge ? saveButton : ''}
        </div>
      </div>
    )
  }
}
AdminChargePanel.propTypes = {
  theme: PropTypes.theme,
  navFn: PropTypes.func.isRequired,
  backFn: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired,
  adminTools: PropTypes.shape({
    updateServiceCharge: PropTypes.func
  }).isRequired,
  charge: PropTypes.shape({
    id: PropTypes.number
  }),
  hub: PropTypes.hub
}

AdminChargePanel.defaultProps = {
  theme: null,
  charge: null,
  hub: null
}

export default AdminChargePanel

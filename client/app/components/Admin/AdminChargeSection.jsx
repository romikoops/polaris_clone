import React, { Component } from 'react'
import Select from 'react-select'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import { serviceChargeNames, currencyOptions } from '../../constants/admin.constants'
import styles from './Admin.scss'
import '../../styles/select-css-custom.scss'

export class AdminChargeSection extends Component {
  constructor (props) {
    super(props)
    this.handleCurrencyChange = this.handleCurrencyChange.bind(this)
  }
  handleCurrencyChange (val) {
    const { setCurrency, tag } = this.props
    setCurrency(val, tag)
  }
  render () {
    const {
      tag, handleEdit, currency, editCharge, editVal, value, editCurr
    } = this.props
    const StyledSelect = styled(Select)`
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
    const editable = (
      <div className={`flex-50 layout-row layout-align-space-between-center ${styles.input_box}`}>
        <input className="flex-45" type="number" onChange={handleEdit} name={tag} value={editVal} />
        <StyledSelect
          name="currency"
          className={` flex-45 ${styles.select}`}
          value={editCurr}
          options={currencyOptions}
          onChange={this.handleCurrencyChange}
        />
      </div>
    )
    const display = (
      <div className="flex-50 layout-row layout-align-end-center">
        <p className="flex-none">
          {' '}
          {value} {currency}
        </p>
      </div>
    )
    return (
      <div className={`flex-100 layout-row layout-align-space-between-center ${styles.charge_opt}`}>
        <p className="flex-50"> {serviceChargeNames[tag]}</p>
        {editCharge ? editable : display}
      </div>
    )
  }
}

AdminChargeSection.propTypes = {
  setCurrency: PropTypes.func.isRequired,
  tag: PropTypes.string.isRequired,
  handleEdit: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  currency: PropTypes.string.isRequired,
  editCurr: PropTypes.string.isRequired,
  editVal: PropTypes.string.isRequired,
  editCharge: PropTypes.bool.isRequired
}

export default AdminChargeSection

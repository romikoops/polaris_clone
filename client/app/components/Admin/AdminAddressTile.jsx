import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './Admin.scss'
import { Tooltip } from '../Tooltip/Tooltip'

export class AdminAddressTile extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editor: {},
      showEdit: false
    }
    this.toggleEdit = this.toggleEdit.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.deleteAddress = this.deleteAddress.bind(this)
  }

  toggleEdit () {
    if (!this.state.showEdit) {
      this.setState({ showEdit: true, editor: Object.assign({}, this.props.address) })
    } else {
      this.setState({ showEdit: false })
    }
  }

  handleChange (event) {
    const { name, value } = event.target
    this.setState({ editor: { ...this.state.editor, [name]: value } })
  }
  saveEdit () {
    this.props.saveEdit(this.state.editor)
  }
  deleteAddress () {
    this.props.deleteAddress(this.props.address.id)
  }

  render () {
    const {
      theme,
      address,
      showTooltip,
      tooltip
    } = this.props
    const { showEdit, editor } = this.state
    if (!address) {
      return ''
    }
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const addressData = (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
          <p className={`flex-100 ${styles.super}`}> Street No. </p>
          <p className="flex-none no_m"> {address.street_number} </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
          <p className={`flex-100 ${styles.super}`}> Street </p>
          <p className="flex-none no_m"> {address.street} </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
          <p className={`flex-100 ${styles.super}`}> City </p>
          <p className="flex-none no_m"> {address.city} </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
          <p className={`flex-100 ${styles.super}`}> Zip Code </p>
          <p className="flex-none no_m"> {address.zip_code} </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
          <p className={`flex-100 ${styles.super}`}> Country </p>
          <p className="flex-none no_m"> {address.country} </p>
        </div>
      </div>
    )
    const editorBox = (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            type="text"
            value={editor.street_number}
            name="street_number"
            onChange={this.handleChange}
          />
        </div>
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            type="text"
            value={editor.street}
            name="street"
            onChange={this.handleChange}
          />
        </div>
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            type="text"
            value={editor.city}
            name="city"
            onChange={this.handleChange}
          />
        </div>
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            type="text"
            value={editor.zip_code}
            name="zip_code"
            onChange={this.handleChange}
          />
        </div>
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            type="text"
            value={editor.country}
            name="country"
            onChange={this.handleChange}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-between-center ">
          <RoundButton
            size="full"
            text="Save Edit"
            theme={theme}
            active
            handleNext={this.saveEdit}
          />
          <hr className="flex-100" />
          <RoundButton
            size="full"
            text="Delete"
            theme={theme}
            handleNext={this.deleteAddress}
          />
        </div>
      </div>
    )
    const pencilIcon = showTooltip ? (<Tooltip
      icon="fa-pencil"
      text={tooltip}
      theme={theme}
      toolText
      iconClass
    />)
      : (<i
        className="flex-none fa fa-pencil clip"
        style={textStyle}
      />)
    return (
      <div
        className={` ${
          styles.address_card
        } flex-none layout-row layout-wrap layout-align-start-start`}
      >
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.sec_subheader
          }`}
        >
          <p
            className={` ${styles.sec_subheader_text} ${styles.clip} flex-none no_m`}
            style={textStyle}
          >
            User Location
          </p>
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.toggleEdit}
          >
            {showEdit ? <i
              className="flex-none fa fa-times clip"
              style={textStyle}
            />
              : pencilIcon }
          </div>
        </div>
        {showEdit ? editorBox : addressData}
      </div>
    )
  }
}
AdminAddressTile.propTypes = {
  theme: PropTypes.theme,
  saveEdit: PropTypes.func.isRequired,
  deleteAddress: PropTypes.func.isRequired,
  address: PropTypes.address,
  tooltip: PropTypes.string,
  showTooltip: PropTypes.bool
}

AdminAddressTile.defaultProps = {
  theme: null,
  address: null,
  tooltip: '',
  showTooltip: false
}

export default AdminAddressTile

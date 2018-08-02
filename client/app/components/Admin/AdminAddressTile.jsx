import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Admin.scss'
import userStyles from '../UserAccount/UserAccount.scss'

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
    // ??
    this.props.saveEdit(this.state.editor)
  }
  deleteAddress () {
    // ??
    this.props.deleteAddress(this.props.address.id)
  }

  render () {
    const {
      theme,
      address
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
      <div className={`layout-row flex-100 ${styles.location_address}`}>
        <i className="fa fa-map-marker clip" style={textStyle} />
        <div className="layout-column layout-align-start-start">
          <p className="flex-none">{address.street_number} {address.street} </p>
          <p className="flex-none"><strong>{address.city}</strong></p>
          <p className="flex-none">{address.zip_code} </p>
          <p className="flex-none">{address.country} </p>
        </div>
      </div>
    )
    const editorBox = (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.location_address}`}>
        <div
          className={
            'flex-100 layout-row layout-wrap ' +
            'layout-align-space-between-center input_box_full'
          }
        >
          <input
            placeholder="Street number"
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
            placeholder="Street"
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
            placeholder="City"
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
            placeholder="ZIP Code"
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
            placeholder="Country"
            type="text"
            value={editor.country}
            name="country"
            onChange={this.handleChange}
          />
        </div>
        {/* <div className="flex-100 layout-row layout-wrap layout-align-space-between-center ">
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
        </div> */}
      </div>
    )
    const pencilIcon = (<i
      className="flex-none fa fa-pencil clip"
      style={{ background: '#BDBDBD', paddingRight: '1.7vw' }}
    />)

    return (
      <div
        className="tile_padding  margin_bottom flex-20 layout-row layout-wrap layout-align-start-start"
      >
        <div
          className={`${
            userStyles['location-box']
          } flex layout-row layout-wrap layout-align-start-start`}
        >
          <div
            className={` flex-100 layout-row layout-align-space-between-center  ${
              styles.sec_subheader
            }`}
          >
            <p
              className={` ${styles.sec_subheader_text} ${styles.clip} flex-none no_m`}
              style={textStyle}
            />
            <div
              className="flex-none layout-row layout-align-center-center"
              onClick={this.toggleEdit}
            >
              {showEdit ? (
                <div className={`layout-row flex-100 ${styles.icons_location}`}>
                  <i className="fa fa-check pointy" onClick={this.saveEdit} />
                  <i className={`fa fa-trash pointy ${styles.trashy}`} onClick={this.deleteAddress} />
                  <i
                    className="flex-none fa fa-times clip extra_padding_right"
                    style={{ background: '#BDBDBD', cursor: 'pointer' }}
                  />
                </div>
              )
                : pencilIcon }
            </div>
          </div>
          {showEdit ? editorBox : addressData}
        </div>
      </div>
    )
  }
}
AdminAddressTile.propTypes = {
  theme: PropTypes.theme,
  saveEdit: PropTypes.func.isRequired,
  deleteAddress: PropTypes.func.isRequired,
  address: PropTypes.address
}

AdminAddressTile.defaultProps = {
  theme: null,
  address: null
}

export default AdminAddressTile

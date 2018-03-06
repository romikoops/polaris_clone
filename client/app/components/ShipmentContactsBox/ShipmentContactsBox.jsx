import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './ShipmentContactsBox.scss'
import defs from '../../styles/default_classes.scss'
import errors from '../../styles/errors.scss'
import { ContactCard } from '../ContactCard/ContactCard'
import { capitalize } from '../../helpers/stringTools'
import { gradientTextGenerator } from '../../helpers'

export class ShipmentContactsBox extends Component {
  constructor (props) {
    super(props)
    this.state = {}
    this.newContactData = {
      contact: {
        companyName: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
      },
      location: {
        street: '',
        number: '',
        zipCode: '',
        city: '',
        country: '',
        gecodedAddress: ''
      }
    }
    this.setContactForEdit = this.setContactForEdit.bind(this)
    this.generateContactCard = this.generateContactCard.bind(this)
    this.generateContactSection = this.generateContactSection.bind(this)
    this.placeholderCard = this.placeholderCard.bind(this)
  }

  setContactForEdit (contactData, contactType, contactIndex) {
    this.props.setContactForEdit({
      ...contactData,
      type: contactType,
      index: contactIndex
    })
  }

  placeholderCard (type, i) {
    const errorMessage = (
      <span
        className={errors.error_message}
        style={{ left: '15px', top: '14px', fontSize: '17px' }}
      >
        * Required
      </span>
    )
    const showError = this.props.finishBookingAttempted && type !== 'notifyee'
    return (
      <div
        className={
          `layout-column flex-align-center-center ${styles.placeholder_card} ` +
          `${showError ? styles.with_errors : ''}`
        }
        onClick={() => this.setContactForEdit(Object.assign({}, this.newContactData), type, i)}
      >
        <div className="flex-100 layout-row layout-align-center-center">
          <i
            className={`fa fa-${type === 'notifyee' ? 'plus' : 'mouse-pointer'}`}
            style={{ fontSize: '30px' }}
          />
        </div>
        <h3>
          {type === 'notifyee' ? 'Add' : 'Set'} {capitalize(type)}
        </h3>
        {showError ? errorMessage : ''}
      </div>
    )
  }
  generateContactCard (contactData, contactType) {
    return contactData.contact ? (
      <ContactCard
        contactData={contactData}
        theme={this.props.theme}
        select={this.setContactForEdit}
        key={v4()}
        contactType={contactType}
      />
    ) : (
      this.placeholderCard(contactType)
    )
  }
  generateContactSection (contactData, contactType) {
    const { theme } = this.props
    const textStyle = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }

    return (
      <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
        <div
          className={`${styles.contact_header} flex-100 layout-row layout-align-start-center`}
        >
          <div className="flex-75 layout-row layout-align-start-center">
            <i className="fa fa-user flex-none" style={textStyle} />
            <p className="flex-none">{ capitalize(contactType) }</p>
          </div>
        </div>
        <div className={styles.contact_wrapper}>
          { this.generateContactCard(contactData, contactType) }
        </div>
      </div>
    )
  }
  render () {
    const {
      shipper, consignee, notifyees, theme
    } = this.props
    const textStyle = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const notifyeeContacts =
      notifyees &&
      notifyees.map((notifyee, i) => (
        <div className="flex-50">
          <div className={styles.contact_wrapper}>
            <ContactCard
              contactData={notifyee}
              theme={theme}
              select={() => this.setContactForEdit(notifyee, 'notifyee', i)}
              key={v4()}
              contactType="notifyee"
              removeFunc={() => this.props.removeNotifyee(i)}
            />
          </div>
        </div>
      ))
    notifyeeContacts.push(<div className="flex-50">
      <div className={styles.contact_wrapper}>
        { this.placeholderCard('notifyee', notifyeeContacts.length) }
      </div>
    </div>)

    const firstRowContacts = [
      this.generateContactSection(shipper, 'shipper'),
      this.generateContactSection(consignee, 'consignee')
    ]
    if (this.props.direction === 'import') firstRowContacts.reverse()
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div className="flex-100 layout-row layout-wrap" style={{ height: '185px' }}>
            { firstRowContacts }
          </div>
          <div className="flex-100 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <div className={
                `${styles.contact_header} flex-50 ` +
                'layout-row layout-align-start-center'
              }
              >
                <i className="fa fa-users flex-none" style={textStyle} />
                <p className="flex-none"> Notifyees</p>
              </div>
            </div>
            { notifyeeContacts }
          </div>
        </div>
      </div>
    )
  }
}
ShipmentContactsBox.propTypes = {
  theme: PropTypes.theme,
  removeNotifyee: PropTypes.func.isRequired,
  consignee: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  shipper: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  notifyees: PropTypes.arrayOf(PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  })),
  setContactForEdit: PropTypes.func.isRequired,
  direction: PropTypes.string.isRequired,
  finishBookingAttempted: PropTypes.bool
}

ShipmentContactsBox.defaultProps = {
  theme: null,
  notifyees: [],
  finishBookingAttempted: false
}

export default ShipmentContactsBox

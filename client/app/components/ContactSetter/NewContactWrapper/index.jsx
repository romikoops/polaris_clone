import React, { PureComponent } from 'react'
import PropTypes from '../../../prop-types'
import styles from './NewContactWrapper.scss'
import ContactSetterNewContactWrapperTitle from './Title'
import { ShipmentContactForm } from '../../ShipmentContactForm/ShipmentContactForm'
import AddressBook from '../../AddressBook/AddressBook'

export default class ContactSetterNewContactWrapper extends PureComponent {
  constructor (props) {
    super(props)

    this.components = { ShipmentContactForm, AddressBook }

    this.state = { compName: 'AddressBook' }
  }

  toggleCompName () {
    const compName = this.state.compName === 'AddressBook' ? 'ShipmentContactForm' : 'AddressBook'
    this.setState({ compName })
    if (this.props.updateDimensions != null) this.props.updateDimensions(700)
  }

  render () {
    const { contactType } = this.props

    const { compName } = this.state
    const Comp = this.components[compName]
    const compProps = this.props[`${compName}Props`]

    let backArrow
    if (compName === 'AddressBook') {
      compProps.addContact = () => this.toggleCompName()
    } else {
      backArrow = (
        <div onClick={() => this.toggleCompName()} className={styles.back_arrow}>
          <i className="fa fa-arrow-left" /> Back to Address Book
        </div>
      )
    }

    const thinClass =
      contactType === 'notifyee' && compName === 'ShipmentContactForm'
        ? styles.new_contact_wrapper_thin
        : ''

    return (
      <div className={`${styles.new_contact_wrapper} ${thinClass} `} >
        { backArrow }
        <div className={`${styles.title_sec} layout-row layout-align-center`}>
          <ContactSetterNewContactWrapperTitle contactType={contactType} />
        </div>
        <div className={styles.body}>
          <Comp {...compProps} />
        </div>
      </div>
    )
  }
}

ContactSetterNewContactWrapper.propTypes = {
  contactType: PropTypes.string,
  updateDimensions: PropTypes.func
}

ContactSetterNewContactWrapper.defaultProps = {
  contactType: '',
  updateDimensions: null
}

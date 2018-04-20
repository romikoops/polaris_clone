import React, { PureComponent } from 'react'
// import PropTypes from '../../../prop-types'
import styles from './NewContactWrapper.scss'
import ContactSetterNewContactWrapperTitle from './Title'
import { ShipmentshipmentContactForm } from '../../ShipmentContactForm/ShipmentContactForm'
import AddressBook from '../../AddressBook/AddressBook'

export default class ContactSetterNewContactWrapper extends PureComponent {
  constructor(props) {
    super(props)

    this.components = { ShipmentshipmentContactForm, AddressBook }

    this.state = { compName: 'AddressBook' }
  }

  toggleCompName () {
    const compName = this.state.compName === 'addressBook' ? 'AddressBook' : 'ShipmentContactForm'
    this.setState({ compName })
  }

  render () {
    const { contactType } = this.props

    const { compName } = this.state
    const Comp = this.components[compName]
    const compProps = this.props[`${compName}Props`]

    return (
      <div className={styles.new_contact_wrapper}>
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

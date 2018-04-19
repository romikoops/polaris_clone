import React from 'react'
import { nameToDisplay } from '../../../helpers'
import styles from './ContactSetterAddressBookTitle.scss'

export default function ContactSetterAddressBookTitle ({ contactType }) {
  return (
    <h3 className={styles.title}>
      Choose a  <br />
      <span className={styles.contact_type}> { nameToDisplay(contactType) } </span>
    </h3>
  )
}

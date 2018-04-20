import React from 'react'
import { nameToDisplay } from '../../../../helpers'
import styles from './Title.scss'

export default function ContactSetterNewContactWrapperTitle ({ contactType }) {
  return (
    <h3 className={styles.title}>
      Choose a  <br />
      <span className={styles.contact_type}> { nameToDisplay(contactType) } </span>
    </h3>
  )
}

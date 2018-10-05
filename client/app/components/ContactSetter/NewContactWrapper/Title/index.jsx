import React from 'react'
import { translate } from 'react-i18next'
import { nameToDisplay } from '../../../../helpers'
import styles from './Title.scss'
import PropTypes from '../../../../prop-types'

function ContactSetterNewContactWrapperTitle ({ contactType, t }) {
  return (
    <h3 className={styles.title}>
      {t('account:chooseA')}<br />
      <span className={styles.contact_type}> { nameToDisplay(contactType) } </span>
    </h3>
  )
}

ContactSetterNewContactWrapperTitle.propTypes = {
  contactType: PropTypes.string,
  t: PropTypes.func.isRequired
}

ContactSetterNewContactWrapperTitle.defaultProps = {
  contactType: ''
}

export default translate('account')(ContactSetterNewContactWrapperTitle)

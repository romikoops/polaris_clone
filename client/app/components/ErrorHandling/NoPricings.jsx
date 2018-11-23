import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './errors.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import CircleCompletion from '../CircleCompletion/CircleCompletion'

function NoPricings ({
  theme, t, pageMargin, user, shipmentDispatch
}) {
  let errorMessage = ''
  const pricingButton = (
    <RoundButton
      theme={theme}
      size="small"
      text={t('account:pricings')}
      handleNext={() => shipmentDispatch.goTo('/account/pricings')}
      classNames="flex-100 layout-row layout-align-center-center"
      active
    />
  )
  if (user.role.name === 'agent') {
    errorMessage = t('account:pricingsTab')
  } else {
    errorMessage = t('account:noPricingsTwo')
  }

  return (
    <div
      className={`flex-100 layout-row layout-wrap layout-align-center-center layout-padding ${styles.error_box} ${styles.no_pricings}`}
      style={{ margin: pageMargin }}
    >
      <div className="flex-80 layout-row layout-align-center-center">
        <CircleCompletion
          icon='fa fa-times'
          iconColor='red'
          animated
          optionalText=''
        />
      </div>
      <div className={`flex-100 layout-row layout-align-center-center ${styles.header_style}`}>
        <h1 className="flex-none">{t('account:noPricingsOne')}</h1>
      </div>
      <div className="flex-100 layout-row layout-wrap layout-align-center-center">
        <p className="flex-100 layout-row layout-align-center-center">{errorMessage}</p>
      </div>
      <div className="flex-100 layout-row layout-wrap layout-align-center-center">
        {(user.role.name === 'agent') ? pricingButton : ''}
      </div>
    </div>
  )
}

NoPricings.propTypes = {
  theme: PropTypes.theme.isRequired,
  pageMargin: PropTypes.string,
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  shipmentDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}

NoPricings.defaultProps = {
  pageMargin: ''
}

export default withNamespaces('account')(NoPricings)

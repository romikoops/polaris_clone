import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import PropTypes from '../../../prop-types'
import GenericError from '../../ErrorHandling/Generic'
import styles from './AdminSettings.scss'
import AdminEmailForm from './AdminEmailForm'
import AdminRemarksEditor from './AdminRemarksEditor'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
import { RoundButton } from '../../RoundButton/RoundButton'
import { authenticationActions } from '../../../actions'
import CircleCompletion from '../../CircleCompletion/CircleCompletion'

class AdminSettings extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    const { authenticationDispatch } = this.props

    if (nextProps.authentication.passwordEmailSent) {
      setTimeout(() => {
        authenticationDispatch.updateReduxStore({ passwordEmailSent: false, passwordEmailRequested: false })
      }, 2000)
    }
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  handlePasswordChange () {
    const { authenticationDispatch, authentication } = this.props
    const { email } = authentication.user
    authenticationDispatch.changePassword(email, '')
  }

  render () {
    const {
      t,
      theme,
      tenant,
      tenantDispatch,
      remarkDispatch,
      authentication
    } = this.props

    const {
      expander
    } = this.state

    const adminEmails = (
      <AdminEmailForm
        theme={theme}
        tenant={tenant}
        tenantDispatch={tenantDispatch}
      />
    )

    const quotationRemarks = (
      <AdminRemarksEditor
        theme={theme}
        tenant={tenant}
        tenantDispatch={tenantDispatch}
        remarkDispatch={remarkDispatch}
      />
    )

    return (
      <GenericError theme={theme}>
        <div className={`layout-row flex-100 layout-wrap layout-align-start-center extra_padding ${styles.container}`}>
          <h3>{t('account:accountSettings')}</h3>
          <CollapsingBar
            showArrow
            collapsed={!expander.emails}
            theme={theme}
            mainWrapperStyle={{ background: '#E0E0E0', color: '#4F4F4F', margin: '10px' }}
            handleCollapser={() => this.toggleExpander('emails')}
            contentHeader={t('admin:updateShopEmails')}
            faClass="fa fa-envelope"
            content={adminEmails}
          />
          <CollapsingBar
            showArrow
            collapsed={!expander.remarks}
            theme={theme}
            mainWrapperStyle={{ background: '#E0E0E0', color: '#4F4F4F', margin: '10px' }}
            handleCollapser={() => this.toggleExpander('remarks')}
            contentHeader={t('admin:updateQuotationPDFRemarks')}
            faClass="fa fa-edit"
            content={quotationRemarks}
          />
          <CircleCompletion
            icon="fa fa-check"
            iconColor={theme.colors.primary || 'green'}
            animated={authentication.passwordEmailSent}
            size="50px"
            opacity={authentication.passwordEmailSent ? '1' : '0'}
            optionalText={t('account:checkEmailForPassword')}
          />
          <div className="flex-100 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="medium"
              active
              text={t('user:changeMyPassword')}
              handleNext={this.handlePasswordChange}
            />
          </div>
        </div>
      </GenericError>
    )
  }
}

AdminSettings.propTypes = {
  tenant: PropTypes.tenant.isRequired,
  tenantDispatch: PropTypes.shape({
    updateEmails: PropTypes.func
  }).isRequired,
  remarkDispatch: PropTypes.shape({
    addPdfRemark: PropTypes.func,
    updatePdfRemarks: PropTypes.func
  }).isRequired,
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired
}

AdminSettings.defaultProps = {
  theme: null
}
function mapStateToProps (state) {
  const { authentication } = state

  return { authentication }
}

function mapDispatchToProps (dispatch) {
  return {
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

export default withNamespaces(['account', 'user'])(connect(mapStateToProps, mapDispatchToProps)(AdminSettings))

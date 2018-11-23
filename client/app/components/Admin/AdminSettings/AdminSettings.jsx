import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import GenericError from '../../../components/ErrorHandling/Generic'
import styles from './AdminSettings.scss'
import AdminEmailForm from './AdminEmailForm'
import AdminRemarksEditor from './AdminRemarksEditor'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'

class AdminSettings extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
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

  render () {
    const {
      t,
      theme,
      tenant,
      tenantDispatch,
      remarkDispatch
    } = this.props

    const {
      expander
    } = this.state

    const adminEmails = (<AdminEmailForm
      theme={theme}
      tenant={tenant}
      tenantDispatch={tenantDispatch}
    />)

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
  theme: null,
}

export default withNamespaces('account')(AdminSettings)

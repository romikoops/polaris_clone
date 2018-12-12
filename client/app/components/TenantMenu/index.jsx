import React from 'react'
import styles from './index.scss'
import CollapsingContent from '../CollapsingBar/Content'

class TenantMenu extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
    this.toggleExpander = this.toggleExpander.bind(this)
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  switchTenant (tenant) {
    const { appDispatch } = this.props
    appDispatch.overrideTenant(tenant.value.id)
    this.toggleExpander('tenant')
  }

  render () {
    const { tenant, tenants } = this.props

    return (
      <div>
        <div
          style={{ minHeight: '8px' }}
          className={`${styles.heading} pointy flex-100 layout-row layout-align-space-between-center`}
          onClick={() => this.toggleExpander('tenant')}
        >
          <div
            className={`${styles.tenant_menu} pointy ccb_change_tenant`}
            style={{ boxShadow: '0px 1px 1px rgba(0, 0, 0, 0.15)' }}
          >
            <p>
              {tenant.name}
              (
              {tenant.subdomain}
              ) | Change Tenant
            </p>
          </div>
          <div
            className={`flex-10 layout-row layout-align-center-center ${styles.arrow_index}`}
          >
            <i className={`${!this.state.expander.tenant ? styles.collapsed : ''} fa fa-chevron-down pointy`} />
          </div>
        </div>

        <CollapsingContent
          collapsed={!this.state.expander.tenant}
          wrapperContentClasses={styles.tenant_content}
          content={(
            <div
              className={`${styles.tenant_wrapper} layout-row layout-wrap layout-align-start-start flex-100`}
            >
              {tenants.map(t => (
                <div
                  key={t.value.subdomain}
                  className="pointy emulate_link layout-row flex-33"
                  style={{ paddingRight: '25px', paddingBottom: '7px' }}
                  onClick={() => this.switchTenant(t)}
                >
                  <p>{t.value.subdomain}</p>
                </div>
              ))}
            </div>
          )}
        />
      </div>
    )
  }
}

TenantMenu.defaultProps = {
  tenant: {},
  tenants: []
}

export default TenantMenu

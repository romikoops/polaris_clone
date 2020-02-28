import React from 'react'
import { ThemeContext, TenantContext, UserContext } from '../helpers/contexts'

const ContextProvider = (props) => {
  const {
    user,
    theme,
    tenant,
    children
  } = props

  return (
    <ThemeContext.Provider value={theme}>
      <TenantContext.Provider value={tenant}>
        <UserContext.Provider value={user}>
          {children}
        </UserContext.Provider>
      </TenantContext.Provider>
    </ThemeContext.Provider>
  )
}

ContextProvider.defaultProps = {
  user: null,
  theme: null,
  tenant: null
}

export default ContextProvider

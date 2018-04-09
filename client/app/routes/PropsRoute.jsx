import React from 'react'
import PropTypes from 'prop-types'
import { Route } from 'react-router-dom'
import renderMergedProps from './renderMergedProps'

const PropsRoute = ({ component, ...rest }) => (
  <Route {...rest} render={routeProps => renderMergedProps(component, routeProps, rest)} />
)

PropsRoute.propTypes = {
  component: PropTypes.node.isRequired
}

export default PropsRoute

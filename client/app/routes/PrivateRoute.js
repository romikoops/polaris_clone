import React from 'react';
import { renderMergedProps } from './renderMergedProps';
import { Route, Redirect } from 'react-router-dom';
import PropTypes from 'prop-types';

const PrivateRoute = ({ component, redirectTo, auth, ...rest }) => {
    return (
      <Route {...rest} render={routeProps => {
          return auth.loggedIn() ? (
              renderMergedProps(component, routeProps, rest)
            ) : (
            <Redirect to={{
                pathname: redirectTo,
                state: { from: routeProps.location }
            }}/>
          );
      }}/>
    );
};


PrivateRoute.propTypes = {
    component: PropTypes.any,
    redirectTo: PropTypes.string,
    auth: PropTypes.object
};

export default PrivateRoute;

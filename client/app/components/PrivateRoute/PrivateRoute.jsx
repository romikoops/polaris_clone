import React from 'react';
import { Route, Redirect } from 'react-router-dom';
import { authHeader, getSubdomain } from '../helpers';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
export const PrivateRoute = ({ component: Component, ...rest }) => (
    <Route {...rest} render={props => (
        localStorage.getItem(cookieKey)
            ? <Component {...props} />
            : <Redirect to={{ pathname: '/login', state: { from: props.location } }} />
    )} />
)
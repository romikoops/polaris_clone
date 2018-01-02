
import React from 'react';
import { Route, Redirect } from 'react-router-dom';
export const PrivateRoute = ({ component: Component, user, loggedIn, theme, ...rest }) => (
    <Route {...rest} render={ props => (
        user && loggedIn
            ? <Component theme={theme} {...props} />
            : <Redirect to={{ pathname: '/', state: { from: props.location } }} />
    )} />
);

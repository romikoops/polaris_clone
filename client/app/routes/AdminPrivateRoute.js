import React from 'react';
import { Route, Redirect } from 'react-router-dom';

const isAdmin = (user) => {
  return user && user.role_id === 1 || user && user.role_id === 3;
};

export const AdminPrivateRoute = ({ component: Component, user, loggedIn, ...rest }) => (
    <Route {...rest} render={ props => (
        isAdmin(user) && loggedIn
            ? <Component {...props} />
            : <Redirect to={{ pathname: '/', state: { from: props.location } }} />
	)} />
);

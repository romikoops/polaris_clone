// import React from 'react';
// import { renderMergedProps } from './renderMergedProps';
// import { Route, Redirect } from 'react-router-dom';
// import PropTypes from 'prop-types';

// const PrivateRoute = ({ component, redirectTo, auth, admin, ...rest }) => {
//     // debugger;
//     console.log(admin);
//     console.log(component);
//     return (
//       <Route {...rest} render={routeProps => {
//           return auth.loggedIn ? (
//               renderMergedProps(component, routeProps, rest)
//             ) : (
//             <Redirect to={{
//                 pathname: redirectTo,
//                 state: { from: routeProps.location }
//             }}/>
//           );
//       }}/>
//     );
// };


// PrivateRoute.propTypes = {
//     component: PropTypes.any,
//     redirectTo: PropTypes.string,
//     auth: PropTypes.object
// };

// export default PrivateRoute;

import React from 'react';
import { Route, Redirect } from 'react-router-dom';

export const PrivateRoute = ({ component: Component, user, loggedIn, theme, ...rest }) => (
    <Route {...rest} render={ props => (
        user && loggedIn
            ? <Component theme={theme} {...props} />
            : <Redirect to={{ pathname: '/', state: { from: props.location } }} />
    )} />
);

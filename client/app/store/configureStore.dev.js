import createHistory from 'history/createBrowserHistory';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import { applyMiddleware, createStore, compose } from 'redux';
import { routerMiddleware } from 'react-router-redux';
import rootReducer from '../reducers';
import DevTools from '../containers/DevTools';

export const history = createHistory();
const middleware = routerMiddleware(history);

// export function configureStore(initialState) {
//
//     return createStore(
//         rootReducer,
//         initialState,
//         compose(
//             applyMiddleware(middleware),
//             DevTools.instrument()
//         )
//     );
// }
const loggerMiddleware = createLogger();

export function configureStore(initialState) {
    const store = createStore(rootReducer, initialState, compose(
            applyMiddleware(
                middleware,
                thunkMiddleware,
                loggerMiddleware),
            DevTools.instrument()
        ));

    if (module.hot) {
    // Enable Webpack hot module replacement for reducers
        module.hot.accept('../reducers', () => {
            const nextRootReducer = require('../reducers/index');
            store.replaceReducer(nextRootReducer);
        });
    }

    return store;
}

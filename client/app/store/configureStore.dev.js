import createHistory from 'history/createBrowserHistory';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import { applyMiddleware, createStore, compose } from 'redux';
import { routerMiddleware } from 'react-router-redux';
import rootReducer from '../reducers';
import DevTools from '../containers/DevTools';
import { saveState, loadState } from '../helpers';
import throttle from 'lodash/throttle';
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
const persistedState = loadState();

export function configureStore() {
    const store = createStore(rootReducer, persistedState, compose(
        applyMiddleware(
            middleware,
            thunkMiddleware,
            loggerMiddleware),
        DevTools.instrument()
    ));
    store.subscribe(throttle(() => {
        const oldState = store.getState();
        saveState({
            bookingData: oldState.bookingData,
            tenant: oldState.tenant,
            admin: oldState.admin
        });
    }), 1000);
    if (module.hot) {
    // Enable Webpack hot module replacement for reducers
        module.hot.accept('../reducers', () => {
            const nextRootReducer = require('../reducers/index');
            store.replaceReducer(nextRootReducer);
        });
    }

    return store;
}

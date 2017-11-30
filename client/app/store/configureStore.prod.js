import createHistory from 'history/createBrowserHistory';
import { applyMiddleware, createStore, compose } from 'redux';
import { routerMiddleware } from 'react-router-redux';
import rootReducer from '../reducers';
import thunkMiddleware from 'redux-thunk';
import { saveState, loadState } from '../helpers';
import throttle from 'lodash/throttle';
export const history = createHistory();
const middleware = routerMiddleware(history);
const persistedState = loadState();
export function configureStore() {
    const store = createStore(rootReducer, persistedState, compose(
        applyMiddleware(
            middleware,
            thunkMiddleware)
    ));
    store.subscribe(throttle(() => {
        saveState({
            bookingData: store.getState().bookingData,
            tenant: store.getState().tenant
        });
    }), 1000);
    return store;
}

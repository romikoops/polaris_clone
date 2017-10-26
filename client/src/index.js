import 'babel-polyfill';
import React from 'react';
import {render} from 'react-dom';
import {browserHistory} from 'react-router';
import {syncHistoryWithStore} from 'react-router-redux';
import {AppContainer} from 'react-hot-loader';
import configureStore from './app/store/configureStore';
import Root from './app/containers/Root/Root';
import './index.scss';

const store = configureStore();
const history = syncHistoryWithStore(browserHistory, store);

render(
  <AppContainer>
    <Root store={store} history={history}/>
  </AppContainer>,
  document.getElementById('root')
);

if (module.hot) {
  module.hot.accept('./app/containers/Root/Root', () => {
    const Root = require('./app/containers/Root/Root').default;
    render(
      <AppContainer>
        <Root store={store} history={history}/>
      </AppContainer>,
      document.getElementById('root')
    );
  });
}

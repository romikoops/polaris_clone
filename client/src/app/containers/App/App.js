import React, {
    Component
} from 'react';
import {Header} from '../../components/Header/Header';
import {Landing} from '../Landing/Landing';
import {Router, Route, browserHistory} from 'react-router';
export class App extends Component {
  render() {
    return (
      <div className="app_box">
        <Header/>
        <Router history={browserHistory}>
          <Route path="/landing" component={Landing}/>
        </Router>
      </div>
    );
  }
}

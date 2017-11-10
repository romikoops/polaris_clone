import React, {Component} from 'react';
// import { Link } from 'react-router-dom';
import { Footer } from './Footer/Footer';
import Routes from '../routes';

// const App = () => {
//     <div className="layout-fill layout-column scroll">
//         { Routes }
//         <Footer/>
//     </div>;
// }

class App extends Component {
  constructor() {
    super();
    this.state = {
      tenant: {}
    }
  }
  componentWillMount() {
    const location = window.location;
    const tenantId = "greencarrier";
    console.log(location);
    fetch('http://localhost:3000/get_tenant/' + tenantId)
    .then(results => {
      return results.json();
    }).then(data => {
      console.log(data)
      this.setState(tenant: data);
    })
  }
  render() {
     <div className="layout-fill layout-column scroll">
        
        <Footer/>
    </div>;
  }
}
export default App;
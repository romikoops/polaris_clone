import React, {Component} from 'react';
import PropTypes from 'prop-types';

class ChooseRoute extends Component {
    constructor(props){
      super(props);
    }

    render() {
      return (
        <div className="flex-100 layout-row">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-none layout-row">
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-map-marker"></i>
                </div>
                <div className="flex-55 layout-row layout-wrap">
                  <h4 className="flex-100">Hamburg</h4>
                </div>
              </div>
              <div className="flex-none layout-row">
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-flag-o"></i>
                </div>
                <div className="flex-55 layout-row layout-wrap">
                  <h4 className="flex-100"> Shanghai </h4>
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90">Pickup Date</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> 2017-10-27</strong></p>
                    <p className="flex-50"> 10:30 UTC</p>
                  </div>
              
                </div>
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90"> Date of Departure</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> 2017-10-27</strong></p>
                    <p className="flex-50"> 10:30 UTC</p>
                  </div>
              
                </div>
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90"> ETA terminal</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> 2017-10-27</strong></p>
                    <p className="flex-50"> 10:30 UTC</p>
                  </div>
              
                </div>
            </div>
          </div>
          <div className="flex-25 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
              <p className="flex-none"> Per unit</p>
              <h4 className="flex-none"> 425€</h4>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
              <p className="flex-none"> Per unit</p>
              <h4 className="flex-none"> 425€</h4>
            </div>
          </div>
        </div>
        )
    }
}
ChooseRoute.PropTypes = {
  theme: PropTypes.object
}
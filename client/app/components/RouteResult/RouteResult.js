import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './RouteResult.scss';
import { moment } from '../../constants';
export class RouteResult extends Component {
    constructor(props) {
        super(props);
        console.log(this.props);
    }

    render() {
        const sched = this.props.schedule;
        const { theme } = this.props;
        const schedKey = sched.starthub_id + '-' + sched.endhub_id;
        const borderColour = theme && theme.colors ? '-webkit-linear-gradient(top, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'floralwhite';
        const borderStyle = {
            borderImage: borderColour
        };
        let originHub = {};
        let destHub = {};
        if (this.props.originHubs) {
            this.props.originHubs.forEach(hub =>  {
                if (hub.id === sched.starthub_id) {
                    originHub = hub;
                }
            });
            this.props.destinationHubs.forEach(hub =>  {
                if (hub.id === sched.endhub_id) {
                    destHub = hub;
                }
            });
        }


        return (
          <div className="flex-100 layout-row">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-40 layout-row">
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-map-marker"></i>
                </div>
                 <div className="flex-55 layout-row layout-wrap">
                  <h4 className="flex-100"> {originHub.name} </h4>
                </div>
                <div className="flex-100">
                  <p className="flex-100"> {originHub.code} </p>
                </div>
              </div>
              <div className="flex-15 layout-row layout-wrap layout-align-center-start" >
                <div className="flex-100 layout-row layout-align-center-center dash_border" style={borderStyle}>
                  <i className="fa fa-ship flex-none"></i>
                </div>
              </div>
              <div className="flex-40 layout-row">
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-flag-o"></i>
                </div>
                <div className="flex-55 layout-row layout-wrap">
                  <h4 className="flex-100"> {destHub.name} </h4>
                </div>
                <div className="flex-100">
                  <p className="flex-100"> {destHub.code} </p>
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90">Pickup Date</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> {moment(this.props.pickupDate).format('YYYY-MM-DD')} </strong></p>
                    <p className="flex-50"> {moment(this.props.pickupDate).format('HH:mm')}</p>
                  </div>

                </div>
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90"> Date of Departure</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> {moment(sched.etd).format('YYYY-MM-DD')}</strong></p>
                    <p className="flex-50"> {moment(sched.etd).format('HH:mm')}</p>
                  </div>

                </div>
                <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                  <div className="flex-100 layout-row">
                    <h4 className="flex-90"> ETA terminal</h4>
                  </div>
                  <div className="flex-100 layout-row">
                    <p className="flex-50"> <strong> {moment(sched.eta).format('YYYY-MM-DD')}</strong></p>
                    <p className="flex-50"> {moment(sched.eta).format('HH:mm')}</p>
                  </div>

                </div>
            </div>
          </div>
          <div className="flex-25 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
              <p className="flex-none"> Per unit</p>
              <h4 className="flex-none"> {this.props.fees[schedKey].total.toFixed(2)} </h4>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
              <p className="flex-none"> Per unit</p>
              <h4 className="flex-none"> {this.props.fees[schedKey].total.toFixed(2)} </h4>
            </div>
          </div>
        </div>
        );
    }
}
RouteResult.PropTypes = {
    theme: PropTypes.object,
    schedule: PropTypes.object,
    selectResult: PropTypes.func,
    pickupDate: PropTypes.string,
    fees: PropTypes.object,
    originHubs: PropTypes.array,
    destinationHubs: PropTypes.array
};

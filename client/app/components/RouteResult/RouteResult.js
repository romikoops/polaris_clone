import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './RouteResult.scss';
import { moment } from '../../constants';
import { RoundButton } from '../RoundButton/RoundButton';
export class RouteResult extends Component {
    constructor(props) {
        super(props);
        this.selectRoute = this.selectRoute.bind(this);
    }
    switchIcon(sched) {
        let icon;
        switch(sched.mode_of_transport) {
            case 'ocean':
                icon = <i className="fa fa-ship"/>;
                break;
            case 'air':
                icon = <i className="fa fa-plane"/>;
                break;
            case 'train':
                icon = <i className="fa fa-train"/>;
                break;
            default:
                icon = <i className="fa fa-ship"/>;
                break;
        }
        return icon;
    }
    selectRoute() {
        const { schedule, fees } = this.props;
        const schedKey = schedule.starthub_id + '-' + schedule.endhub_id;
        const totalFees = fees[schedKey].total;
        this.props.selectResult({schedule: schedule, total: totalFees});
    }
    dashedGradient(color1, color2) {
        return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`;
    }
    format2Digit(n) {
      return ('0' + n).slice(-2);
    }
    render() {
        const { theme, schedule } = this.props;
        const schedKey = schedule.starthub_id + '-' + schedule.endhub_id;
        let originHub = {};
        let destHub = {};
        if (this.props.originHubs) {
            this.props.originHubs.forEach(hub =>  {
                if (hub.id === schedule.starthub_id) {
                    originHub = hub;
                }
            });
            this.props.destinationHubs.forEach(hub =>  {
                if (hub.id === schedule.endhub_id) {
                    destHub = hub;
                }
            });
        }
        const gradientFontStyle = {
          background: theme && theme.colors ? `-webkit-linear-gradient(left, ${theme.colors.brightPrimary}, ${theme.colors.brightSecondary})` : 'black',
        };
        const price = this.props.fees[schedKey].total;
        const priceUnits = Math.floor(price);
        const priceCents = this.format2Digit(Math.floor((price * 100) % 100));
        const dashedLineStyles = {
            marginTop: '6px',
            height: '2px',
            width: '100%',
            background: theme && theme.colors ? this.dashedGradient(theme.colors.primary, theme.colors.secondary) : 'black',
            backgroundSize: '16px 2px, 100% 2px'
        };
        return (
          <div key={schedule.id} className={`flex-100 layout-row ${styles.route_result}`}>
            <div className="flex-75 layout-row layout-wrap">
              <div className={`flex-100 layout-row layout-align-start-center ${styles.top_row}`}>
                <div className={`${styles.header_hub}`}>
                  <i className={`fa fa-map-marker ${styles.map_marker}`}></i>
                  <div className="flex-100 layout-row">
                    <h4 className="flex-100"> {originHub.name} </h4>
                  </div>
                  <div className="flex-100">
                    <p className="flex-100"> {originHub.hub_code ? originHub.hub_code : 'Code Unavailable'} </p>
                  </div>
                </div>
                <div className={`${styles.connection_graphics}`} >
                  <div className="flex-none layout-row layout-align-center-center">
                    {this.switchIcon(schedule)}
                  </div>
                  <div style={dashedLineStyles}></div>
                </div>
                <div className={`${styles.header_hub}`}>
                  <i className={`fa fa-flag-o ${styles.flag}`}></i>
                  <div className="flex-100 layout-row">
                    <h4 className="flex-100"> {destHub.name} </h4>
                  </div>
                  <div className="flex-100">
                    <p className="flex-100"> {destHub.hub_code ? destHub.hub_code : 'Code Unavailable'} </p>
                  </div>
                </div>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                  <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                    <div className="flex-100 layout-row">
                      <h4 className={styles.date_title} style={gradientFontStyle}>Pickup Date</h4>
                    </div>
                    <div className="flex-100 layout-row">
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(this.props.pickupDate).format('YYYY-MM-DD')} </p>
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(this.props.pickupDate).format('HH:mm')} </p>
                    </div>

                  </div>
                  <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                    <div className="flex-100 layout-row">
                      <h4 className={styles.date_title} style={gradientFontStyle}> Date of Departure</h4>
                    </div>
                    <div className="flex-100 layout-row">
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(schedule.eta).format('YYYY-MM-DD')} </p>
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(schedule.eta).format('HH:mm')} </p>
                    </div>

                  </div>
                  <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                    <div className="flex-100 layout-row">
                      <h4 className={styles.date_title} style={gradientFontStyle}> ETA terminal</h4>
                    </div>
                    <div className="flex-100 layout-row">
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(schedule.eta).format('YYYY-MM-DD')} </p>
                      <p className={`flex-none ${styles.sched_elem}`}> {moment(schedule.eta).format('HH:mm')} </p>
                    </div>

                  </div>
              </div>
            </div>
            <div className="flex-25 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
                <p className="flex-none">Total price: </p>
                <h4 className={`flex-none ${styles.total_price}`}>
                  {priceUnits}<sup>.{priceCents}</sup>  <span className={styles.total_price_currency}>EUR</span>
                </h4>
              </div>
              <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
                <RoundButton text={'Choose'} size="full" handleNext={this.selectRoute} theme={theme} active/>
              </div>
            </div>
          </div>
        );
    }
}
RouteResult.propTypes = {
    theme: PropTypes.object,
    schedule: PropTypes.object,
    selectResult: PropTypes.func,
    pickupDate: PropTypes.string,
    fees: PropTypes.object,
    originHubs: PropTypes.array,
    destinationHubs: PropTypes.array
};

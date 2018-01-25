import React, { Component } from 'react';
import { appActions } from '../../actions';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { moment } from '../../constants';
class CacheClearer extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    componentDidMount() {
      this.startCheck();
    }
    componentWillUnmount() {
      this.cancelCheck();
    }
    checkState() {
      const resetTime = localStorage.getItem('lastReset');
      const timeShed = resetTime ? resetTime : 00000000;
      const requestOptions = {
        method: 'GET',
        headers: authHeader()
      };
      return fetch(BASE_URL + '/messaging/get', requestOptions).then(
          data => {
            if (data.reset && moment(data.reset.time).isAfter(moment(resetTime))) {
              localStorage.removeItem("state");
              localStorage.removeItem("user");
              localStorage.removeItem("authHeader");
              localStorage.setItem("lastReset", moment().format('x'));
            }
          }
        )
      }
    startCheck() {
      const interval = setInterval(() => {
        this.checkState()
      }, 3600)
      this.setState({interval});
    }
    cancelCheck() {
      clearInterval(this.state.interval);
    }
    
    render() {
        const  {  users, authentication, tenant, bookingData, admin } = this.props;
        
        return (
            <div className="flex-none layout-row layout-wrap layout-align-center-center">
            </div>
        );
    }
}
function mapStateToProps(state) {
    const { users, authentication, tenant, bookingData, admin } = state;
    return {
        users, authentication, tenant, bookingData, admin
    };
}
function mapDispatchToProps(dispatch) {
    return {
        appDispatch: bindActionCreators(appActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(CacheClearer));

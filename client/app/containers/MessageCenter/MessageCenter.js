import React, { Component } from 'react';
class MessageCenter extends Component {
  constructor(props) {
  }

  render() {
    const  { theme, close, messageDispatch } this.props;
    return (
      <div className={`flex-none layout-row layout-wrap ${styles.backdrop}`} onClick={() => close()}></div>
    )
  }
}
function mapStateToProps(state) {
    const { users, authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        tenant,
        theme: tenant.data.theme,
        loggedIn,
        adminData: admin
    };
}
function mapDispatchToProps(dispatch) {
    return {
        messageDispatch: bindActionCreators(messageActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(MessageCenter));

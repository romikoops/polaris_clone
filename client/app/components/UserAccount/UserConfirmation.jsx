import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { userActions } from '../../actions'
import CircleCompletion from '../CircleCompletion/CircleCompletion'

class UserConfirmation extends Component {
  static getDerivedStateFromProps (nextProps, prevState) {
    if (nextProps.users && nextProps.users.confirmed) {
      return {
        confirmed: true
      }
    }

    return {
      ...prevState
    }
  }

  constructor (props) {
    super(props)

    this.state = {
      confirmed: false
    }
  }

  componentDidMount () {
    const { userDispatch, location } = this.props
    const token = location.pathname.split('/').slice(-1)[0]
    userDispatch.confirmAccount(token)
  }

  render () {
    const { t, user, theme } = this.props
    const { confirmed } = this.state

    return (
      <div className="layout-row layout-align-center-center flex-100">
        { confirmed ? (
          <div>
            <CircleCompletion
              icon="fa fa-check"
              iconColor={theme.colors.primary || 'green'}
              animated
              size="100px"
            />
            <h4>
              {t('user:accountConfirmation', { firstName: user.first_name })}
            </h4>
          </div>
        )
          : (
            <div>
              <CircleCompletion
                icon="fa fa-times"
                iconColor="red"
                animated
                size="100px"
              />
              <h4>
                {t('user:confirmationIssue')}
              </h4>
            </div>
          )}
      </div>
    )
  }
}

function mapStateToProps (state) {
  const {
    authentication, users
  } = state
  const { user } = authentication

  return {
    user,
    users
  }
}

function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces('user')(UserConfirmation))

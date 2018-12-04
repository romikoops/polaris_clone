import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import {
  AdminWizardHubs,
  AdminWizardServiceCharges,
  AdminWizardPricings,
  AdminWizardTrucking,
  AdminWizardFinished
} from './'
import { RoundButton } from '../../RoundButton/RoundButton'
import { adminActions } from '../../../actions'
import TextHeading from '../../TextHeading/TextHeading'
import GenericError from '../../ErrorHandling/Generic'

class AdminWizard extends Component {
  constructor (props) {
    super(props)
    this.state = {
      stage: 1
    }
    this.start = this.start.bind(this)
  }
  nextStep () {
    this.setState({ stage: this.state.stage + 1 })
  }
  start () {
    this.props.adminDispatch.goTo('/admin/wizard/hubs')
  }

  render () {
    const {
      t, theme, adminDispatch, wizard
    } = this.props
    let newHubs = []
    let newScs = []
    if (wizard) {
      // eslint-disable-next-line prefer-destructuring
      newHubs = wizard.newHubs
      // eslint-disable-next-line prefer-destructuring
      newScs = wizard.newScs
    }
    // const { newHubs } = wizard;
    const StartView = ({ innerTheme }) => (
      <div className="layout-fill layout-row layout-align-center-center">
        <RoundButton
          theme={innerTheme}
          size="small"
          active
          text={t('admin:begin')}
          handleNext={this.start}
          iconClass="fa-magic"
        />
      </div>
    )

    return (
      <GenericError>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">
            <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
              <TextHeading theme={theme} size={1} text="Set Up Wizard" />
            </div>
            <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
              <TextHeading
                theme={theme}
                size={3}
                text="WARNING: Your existing data might be overwritten!"
                warning
              />
            </div>
            <Switch className="flex">
              <Route
                exact
                path="/admin/wizard"
                render={props => <StartView theme={theme} {...props} />}
              />
              <Route
                exact
                path="/admin/wizard/hubs"
                render={props => (
                  <AdminWizardHubs
                    theme={theme}
                    {...props}
                    adminTools={adminDispatch}
                    newHubs={newHubs}
                  />
                )}
              />
              <Route
                exact
                path="/admin/wizard/service_charges"
                render={props => (
                  <AdminWizardServiceCharges
                    theme={theme}
                    {...props}
                    adminTools={adminDispatch}
                    newScs={newScs}
                  />
                )}
              />
              <Route
                exact
                path="/admin/wizard/pricings"
                render={props => (
                  <AdminWizardPricings
                    theme={theme}
                    {...props}
                    adminTools={adminDispatch}
                    newScs={newScs}
                  />
                )}
              />
              <Route
                exact
                path="/admin/wizard/trucking"
                render={props => (
                  <AdminWizardTrucking
                    theme={theme}
                    {...props}
                    adminTools={adminDispatch}
                    newScs={newScs}
                  />
                )}
              />
              <Route
                exact
                path="/admin/wizard/finished"
                render={props => (
                  <AdminWizardFinished
                    theme={theme}
                    {...props}
                    adminTools={adminDispatch}
                    newScs={newScs}
                  />
                )}
              />
            </Switch>
          </div>
        </div>
      </GenericError>
    )
  }
}
AdminWizard.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  wizard: PropTypes.shape({
    newHubs: PropTypes.array,
    newScs: PropTypes.array
  }),
  adminDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired
}

AdminWizard.defaultProps = {
  wizard: null,
  theme: null,
  hubs: []
}

function mapStateToProps (state) {
  const { authentication, app, admin } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const { clients, hubs, wizard } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    wizard,
    clients
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminWizard))

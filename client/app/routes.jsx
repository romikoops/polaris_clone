import React from 'react'
import { Switch } from 'react-router-dom'
import { Landing } from './containers/Landing/Landing'
import { PropsRoute } from './routes/PropsRoute'

export default (
  <Switch className="flex">
    <PropsRoute path="/landing" component={Landing} tenant={this.state.tenant} />
  </Switch>
)

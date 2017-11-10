import React from 'react';
import { Switch } from 'react-router-dom';
import {Landing} from './containers/Landing/Landing';
import { PropsRoute } from './routes/PropsRoute';
// import { PrivateRoute } from './routes/PrivateRoute';

export default (
	<Switch className="flex">
		<PropsRoute path="/landing" component={Landing} tenant={this.state.tenant}/>
	</Switch>
);

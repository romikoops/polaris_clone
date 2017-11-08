import React from 'react';
import { Route, Switch } from 'react-router-dom';
import FilterableTable from './containers/FilterableTable';
import {Landing} from './containers/Landing/Landing';

export default (
	<Switch className="flex">
		<Route exact path="/" component={FilterableTable} />
		<Route path="/landing" component={Landing} />
	</Switch>
);

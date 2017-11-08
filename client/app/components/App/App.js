import React from 'react';
// import { Link } from 'react-router-dom';
import { Footer } from '../Footer/Footer';
import Routes from '../../routes';
import './App.scss';

const App = () =>
    <div className="layout-fill layout-column scroll">
        { Routes }
        <Footer className="flex-none"/>
    </div>;

export default App;

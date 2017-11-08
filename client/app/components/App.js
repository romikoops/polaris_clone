import React from 'react';
// import { Link } from 'react-router-dom';
import { Footer } from './Footer/Footer';
import Routes from '../routes';

const App = () =>
    <div className="layout-fill layout-column scroll">
        { Routes }
        <Footer/>
    </div>;

export default App;

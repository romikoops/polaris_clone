import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './BlogPostHighlights.scss';
import { RoundButton } from '../RoundButton/RoundButton';
import Truncate from 'react-truncate';
export class BlogPostHighlights extends Component {
    render() {
        const dummyPosts = [
            {
                title: 'How Digitalisation is changing shipping',
                text: 'With the sheer amount of freight crossing the globe on a daily basis, our means of co-ordinating the massive flow of information ahs had to continuously evolve and adapt. Digitalisation has allowed companies, big and small to keep up with the ever',
                image: 'https://assets.itsmycargo.com/assets/cityimages/shipping-containers_sm.jpg'
            },
            {
                title: 'With greater supply and even higher demand, efficiency gains have never been more important',
                text: 'With the global freight market under pressure from both supply and demand sides, it has become increasingly important to eek out every last bit of productivity from your existing resources',
                image: 'https://assets.itsmycargo.com/assets/cityimages/shipping-containers_sm.jpg'
            },
            {
                title: 'Blockchain is coming: How you can begin to get ready for the next big leap in freight',
                text: 'The global shipping industry is the backbone upon which the modern world is built. However, fraud, theft and other problems continue to drive up prices for consumers around the world. A small group  of companies are working to bring the power and protection of blockchain technologies to the wolrd of freight',
                image: 'https://assets.itsmycargo.com/assets/cityimages/shipping-containers_sm.jpg'
            }
        ];
        const theme = this.props.theme;
        const postArray = [];
        dummyPosts.forEach((dp, i) => {
            const divStyle = {
                backgroundImage: 'url(' + dp.image + ')'
            };
            const dbp = (<div key={i} className={styles.blog_post + ' layout-column no_max'}>
                <div className={styles.bp_image + ' flex-33'} style={divStyle}></div>
                <div className="flex-66 layout-column layout-align-center-start">
                    <div className={'flex-66 layout-column layout-align-start-center ' + styles.bp_text}>
                        <div className="flex-33 layout-row layout-align-center-start" style={{width: '100%'}}>
                            <h3 className="flex-100"> <Truncate lines={1} >{dp.title} </Truncate> </h3>
                        </div>
                        <div className="flex-66 layout-row layout-align-center-center" style={{width: '100%'}}>
                            <p className="flex-100"> <Truncate lines={4} >{dp.text} </Truncate></p>
                        </div>
                    </div>
                    <div className={'flex-33 layout-row layout-wrap layout-align-center-center ' + styles.bp_action}>
                        <RoundButton text="Read More" theme={theme} active/>
                    </div>
                </div>
            </div>
            );
            postArray.push(dbp);
        });
        return (

            <div className={'flex-100 layout-row layout-wrap layout-align-center-center ' + styles.blog_post_highlights}>
                <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>
                    <h2 className="flex-none"> Recent Blog News</h2>
                </div>
                <div className="flex-100 flex-gt-sm-75 layout-row layout-align-center-center">
                    {postArray}
                </div>
            </div>
        );
    }
}

BlogPostHighlights.propTypes = {
    theme: PropTypes.object
};

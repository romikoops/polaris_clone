import React, {Component} from 'react';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import styles from '../ActiveRoutes/ActiveRoutes.scss';
import {v4} from 'node-uuid';
export class Carousel extends Component {
    render() {
      if (!this.props.slides) {
        return '';
      }
      const slideNumber = this.props.noSlides ? this.props.noSlides : 4;
        const settings = {
            dots: true,
            autoplay: true,
            infinite: true,
            slidesToShow: slideNumber,
            speed: 2000,
            arrows: true
        };
        const slides = this.props.slides.map((route) => {
            const divStyle = {
                backgroundImage: 'url(' + route.image + ')'
            };
            return (
                <div key={v4()} className={styles.slick_slide + ' flex-none layout-row layout-align-center-center'} style={divStyle}>
                    {this.props.fade ? <div className={`flex-none ${styles.fade}`}></div> : ''}
                    <div className={`flex-none layout-column layout-align-center-center ${styles.slick_content}`}>
                        <h2 className={styles.slick_city + ' flex-none'}> {route.header} </h2>
                        <h5 className={styles.slick_country + ' flex-none'}> {route.subheader} </h5>
                    </div>
                </div>
            );
        });
        return (
            <div className={`flex-100 layout-row ${styles.slider_container}`}>
                <Slider {...settings}>
                    {slides}
                </Slider>
            </div>
        );
    }
}

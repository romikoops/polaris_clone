import React from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './BlogPostHighlights.scss'
import { RoundButton } from '../RoundButton/RoundButton'

const containerBase = 'flex-100 layout-row layout-wrap layout-align-center-center'
const row = 'layout-row layout-align-center-center'

const CENTER_START = 'layout-column layout-align-center-start'
const CONTAINER = `${containerBase} ${styles.blog_post_highlights}`
const POST = `${styles.blog_post} layout-column`
const POSTS = `flex-100 flex-gt-sm-75 ${row}`
const RECENT = `${styles.service_label} ${row} flex-100`
const SHORT_ROW = `flex-33 layout-wrap ${row} ${styles.bp_action}`
const START_CENTER = 'layout-column layout-align-start-center'
const TITLE = 'flex-33 layout-row layout-align-center-start'
const WIDE_ROW = `flex-66 ${row}`

const widthStyle = { width: '100%' }

const dummyPosts = [
  {
    title: 'How Digitalisation is changing shipping',
    text:
      'With the sheer amount of freight crossing the globe on a daily basis, our means of co-ordinating the massive flow of information ahs had to continuously evolve and adapt. Digitalisation has allowed companies, big and small to keep up with the ever',
    image: 'https://assets.itsmycargo.com/assets/cityimages/shipping-containers_sm.jpg'
  },
  {
    title:
      'With greater supply and even higher demand, efficiency gains have never been more important',
    text:
      'With the global freight market under pressure from both supply and demand sides, it has become increasingly important to eek out every last bit of productivity from your existing resources',
    image: 'https://assets.itsmycargo.com/assets/images/dashboard/freight_455x305.jpg'
  },
  {
    title:
      'Blockchain is coming: How you can begin to get ready for the next big leap in freight',
    text:
      'The global shipping industry is the backbone upon which the modern world is built. However, fraud, theft and other problems continue to drive up prices for consumers around the world. A small group  of companies are working to bring the power and protection of blockchain technologies to the wolrd of freight',
    image: 'https://assets.itsmycargo.com/assets/images/dashboard/ship_450x298.jpeg'
  }
]

const generatePosts = (input, theme) => input.map((dp, i) => {
  const backgroundStyle = { backgroundImage: `url(${dp.image})` }

  const post = (
    // eslint-disable-next-line react/no-array-index-key
    <div key={i} className={POST}>
      <div className={`${styles.bp_image} flex-33`} style={backgroundStyle} />
      <div className={`flex-66 ${CENTER_START}`}>
        <div className={`flex-66 ${START_CENTER} ${styles.bp_text}`}>

          <div className={TITLE} style={widthStyle}>
            <h3 className="flex-100">
              {' '}
              <Truncate lines={1}>{dp.title} </Truncate>
              {' '}
            </h3>
          </div>

          <div className={WIDE_ROW} style={widthStyle}>
            <p className="flex-100">
              {' '}
              <Truncate lines={4}>{dp.text} </Truncate>
            </p>
          </div>
        </div>

        <div className={SHORT_ROW}>
          <RoundButton text="Read More" theme={theme} active />
        </div>
      </div>
    </div>
  )

  return post
})

export function BlogPostHighlights ({ theme }) {
  const postArray = generatePosts(dummyPosts, theme)

  return (
    <div
      className={CONTAINER}
    >
      <div className={RECENT}>
        <h2 className="flex-none"> Recent Blog News</h2>
      </div>
      <div className={POSTS}>
        {postArray}
      </div>
    </div>
  )
}

BlogPostHighlights.propTypes = {
  theme: PropTypes.theme
}

BlogPostHighlights.defaultProps = {
  theme: null
}

export default BlogPostHighlights

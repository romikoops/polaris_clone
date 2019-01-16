import React from 'react'
import PropTypes from '../../prop-types'
import styles from './CardLinkRow.scss'
import CardLink from '../CardLink/CardLink'

export function CardLinkRow ({
  cards, handleClick, theme, selectedType, allowedCargoTypes
}) {
  const cardLinks = cards.map(card => (
    <CardLink
      key={card.name}
      text={card.name}
      img={card.img}
      path={card.url}
      code={card.code}
      allowedCargoTypes={allowedCargoTypes}
      selectedType={selectedType}
      handleClick={card.handleClick ? card.handleClick : handleClick}
      theme={theme}
      options={card.options}
    />
  ))

  return (
    <div className={`${styles.card_link_row} layout-row layout-wrap flex-100 layout-align-space-around-center`}>
      {cardLinks}
    </div>
  )
}

CardLinkRow.propTypes = {
  theme: PropTypes.theme,
  cards: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string,
    img: PropTypes.string,
    url: PropTypes.string,
    handleClick: PropTypes.func,
    options: PropTypes.object
  })).isRequired,
  selectedType: PropTypes.string,
  handleClick: PropTypes.func.isRequired,
  allowedCargoTypes: PropTypes.objectOf(PropTypes.bool)
}

CardLinkRow.defaultProps = {
  theme: null,
  selectedType: '',
  allowedCargoTypes: {}
}

export default CardLinkRow

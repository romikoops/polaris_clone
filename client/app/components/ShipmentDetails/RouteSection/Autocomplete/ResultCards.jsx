import React from 'react'
import { v4 as uuidv4 } from 'uuid'
import styles from './index.scss'

function ResultsCards (props) {
  const {
    areaResults, combinedResults, highlightIndex,
    handleAddress, t, theme
  } = props

  const highlightStyle = {
    borderBottom: `5px solid ${theme.colors.primary}`
  }

  if (combinedResults.length < 1) {
    return (
      <div
        className={`flex-100 layout-row layout-align-center-center pointy ${styles.autocomplete_card}`}
        key={uuidv4()}
      >
        <p className="flex">{t('common:noResults')}</p>
      </div>
    )
  }

  function generateCards (results) {
    return (results.filter(
      result => !areaResults.some(
        element => element.description === result.description
      )
    )
      .map((result, i) => {
        if (result.separator === true) {
          return (
            <div
              className={`flex-100 layout-row layout-align-start-center ${styles.results_section_header}`}
              key={result.label}
            >
              <p className="flex-none">
                {' '}
                {result.label}
              </p>
            </div>
          )
        }
        const isHighlighted = highlightIndex === i

        return (
          <div
            className={`flex-100 layout-row layout-align-center-center
          ${styles.autocomplete_card} pointy ccb_result`}
            style={isHighlighted ? highlightStyle : {}}
            onClick={() => handleAddress(result)}
            key={uuidv4()}
          >
            <p className="flex">
              {result.label || result.description}
            </p>
          </div>
        )
      })
    )
  }

  const combinedCards = generateCards(combinedResults)

  return (
    <div
      className="flex-100"
    >
      {' '}
      {combinedCards}
    </div>
  )
}

export default ResultsCards

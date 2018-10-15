import React from 'react'

export function determineSortingCaret (key, sorted) {
  const sortInQuestion = sorted.filter(x => x.id === key)[0]
  if (!sortInQuestion) {
    return <i />
  }
  if (sortInQuestion.desc) {
    return (<i className="flex-none fa fa-sort-amount-desc five_p" />)
  }

  return (<i className="flex-none fa fa-sort-amount-asc five_p" />)
}

export default determineSortingCaret

import styles from './index.scss'

export default function shouldBlur (row, expandedIndexes) {
  if (expandedIndexes.length === 0 || expandedIndexes.includes(String(row.viewIndex))) {
    return ''
  }

  return styles.unselected
}

export default function toggleCSS (theme) {
  return (
    `
      .aggregated_cargo.react-toggle .react-toggle-track {
        background: rgba(0, 0, 0, 0.2);
        border: 0.5px solid rgba(0, 0, 0, 0.1);
      }
      .aggregated_cargo.react-toggle .react-toggle-thumb {
        border: 0.5px solid rgba(0, 0, 0, 0.1);
      }
      
      .aggregated_cargo.react-toggle:hover:not(.react-toggle--disabled) .react-toggle-track {
        background: rgba(0, 0, 0, 0.4);
      }
      .aggregated_cargo.react-toggle--checked:hover:not(.react-toggle--disabled) .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.brightSecondary} 100%
        );
        border: 0.5px solid rgba(0, 0, 0, 0.1);
        opacity: 0.9;
      }

      .aggregated_cargo.react-toggle--checked .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.brightSecondary} 100%
        );
        border: 0.5px solid rgba(0, 0, 0, 0.1);
      }
    `
  )
}

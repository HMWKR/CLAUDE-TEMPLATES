# Playwright Selectors Reference

## Selector Priority (recommended order)
1. Role: page.getByRole
2. Text: page.getByText
3. Label: page.getByLabel
4. Test ID: page.getByTestId
5. CSS: page.locator

## Wait Strategies
- networkidle, domcontentloaded, load, selector

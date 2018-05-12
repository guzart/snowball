# Debt Snowball for YNAB

## TODO

* calculate current screen from model
* load budgets if not available - fire when setting the screen?
* extract action footer to function
* add reset button to error screen

### Alpha Release

* choose a budget
* choose your accounts
* debt details
* debt payment categories
* debt strategies
  * [ ] highest interest rate first
  * [ ] lowest interest rate first
  * [ ] Balance/Min Payment Ratio
  * [ ] Minimum Payment Only
* debt strategy details
* "start over" button

### Beta Release

* [ ] Use types for accountId, budgetId, etc
* [ ] create category modal
* [ ] button to purge localStorage
* [ ] postcss with auto prefixer
* [ ] test that session is decoded correctly
* [ ] handle session decode error
* [ ] handle api url decode error
* [ ] use budget number formatting
* [ ] use budget date formatting
* [ ] move temporary selections out of session – bug when back and forward session is saved

### Bling, bling! ✨🥇

* [ ] preserve order of accounts
* [ ] customize bootstrap style
* [ ] update debt payment category balance from snowball
* [ ] animate screen transitions
* [ ] manifest with service workers
* [ ] remove unused css from bootstrap
* [ ] transform png logo with svg and remove margin
* [ ] update to [webpack-serve](https://github.com/webpack-contrib/webpack-serve)

## Links

* [Animation](https://github.com/mdgriffith/elm-animation-flower-menu/blob/master/src/FlowerMenu.elm)

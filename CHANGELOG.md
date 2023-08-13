# Changelog

## 1.1.1 (2023-08-13)

- Fix error in error message (sic) when hackney is missing
- Documentation improvements; adding a LiveView example

## 1.1.0 (2021-03-27)

- Replace HTTPoison with hackney
- Make hackney optional, allow passing a custom HTTPClient

## 1.0.0 (2020-04-13)

### Changed
- When used incorrectly, instead of custom usage info, mix tasks will print the same message as running `mix help ...` would print
- Lowered required `httpoison` and `jason` versions to `~> 1.0`

## 1.0.0-rc.1 (2020-04-11)
- Initial release candidate

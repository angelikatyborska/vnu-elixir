# Changelog

## Unreleased

- Remove the built-in `Vnu.HTTPClient.Hackney` HTTP client adapter and replace it with `Vnu.HTTPClient.Httpc` as the default.
  - Note: If you're configuring a `https://` VNU `server_url`, be aware that the new adapter relies on `:httpc`'s built-in secure TLS defaults (peer certificate verification against the OS trust store, hostname checking), which were added in **Erlang/OTP 26+**.
- Remove the `:hackney` mix dependency

## 1.2.0 (2026-06-27)

- Dropping support for Elixir 1.14.
- Fix crash when `server_url` contains query params.

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

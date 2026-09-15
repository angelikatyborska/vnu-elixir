# Changelog

## Unreleased

### Breaking changes

- Require Erlang/OTP 26 or newer.
- Remove the built-in `Vnu.HTTPClient.Hackney` HTTP client adapter and replace it with `Vnu.HTTPClient.Httpc` as the default.
  - Note: If you're configuring a `https://` VNU `server_url`, be aware that the new adapter relies on `:httpc`'s built-in secure TLS defaults (peer certificate verification against the OS trust store, hostname checking), which were added in **Erlang/OTP 26+**.

### Upgrade instructions

1. Make sure your project runs on Erlang/OTP 26 or newer.
2. In `mix.exs`, remove `runtime: false` from the `:vnu` dependency.

   ```elixir
   # before
   {:vnu, "~> 1.2", only: [:dev, :test], runtime: false}
   # after
   {:vnu, "~> 2.0", only: [:dev, :test]}
   ```

  This, in combination with `vnu-elixir`'s `extra_applications` setting in `mix.exs`, ensures that the `:inets` and `:ssl` applications are available for the default HTTP client adapter.

3. (optional) If your project doesn't use `hackney`, also remove the `{:hackney, ...}` dependency from `mix.exs` and run `mix deps.unlock --unused`.
4. (optional) If you explicitly set the `http_client: Vnu.HTTPClient.Hackney` config option, remove it or update to use the new `Vnu.HTTPClient.Httpc` default.

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

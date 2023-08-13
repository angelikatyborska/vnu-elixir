# Vnu usage examples

All examples assume that the Checker server is running on `localhost:8888`.

## 1. Phoenix app

Take a look at file `1_phoenix_app/test/phoenix_app_web/controllers/page_controller_test.exs` to see the usage of assertions.

Run `mix test` to see the tests failing for invalid HTML and CSS documents.

![](../assets/controller_test.png)

You can change the Checker server URL in `1_phoenix_app/config/test.exs`:
   
   ```elixir
   config :phoenix_app, :vnu_server_url, "http://localhost:8888"
   ```

Run `mix vnu.validate.css --server-url http://localhost:8888 assets/**/*.css` to test the mix task.

![](../assets/mix_task.png)

defmodule PhoenixAppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PhoenixAppWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint PhoenixAppWeb.Endpoint

      use PhoenixAppWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import PhoenixAppWeb.ConnCase

      def assert_valid_html(html, vnu_opts \\ []) do
        default_vnu_opts = [
          server_url: Application.get_env(:phoenix_app, :vnu_server_url),
          fail_on_warnings: true
        ]

        Vnu.Assertions.assert_valid_html(html, Keyword.merge(default_vnu_opts, vnu_opts))
      end
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

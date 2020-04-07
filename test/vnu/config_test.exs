defmodule Vnu.ConfigTest do
  use ExUnit.Case
  alias Vnu.{Config, Error}

  describe "new" do
    test "defaults" do
      {:ok, config} = Config.new([])
      assert config == %Config{server_url: "http://localhost:8888", format: :html}
    end

    test "trims trailing slash from server_url" do
      {:ok, config} = Config.new(server_url: "http://localhost:1234/")
      assert config.server_url == "http://localhost:1234"
    end

    test "server_url must be a string" do
      {:error, %Error{} = error} = Config.new(server_url: 1)

      assert error.reason == :invalid_config
      assert error.message == "Expected server_url to be a string, got: 1"
    end

    test "format must be one of known values" do
      {:ok, config} = Config.new(format: :html)
      assert config.format == :html
      {:ok, config} = Config.new(format: :css)
      assert config.format == :css
      {:ok, config} = Config.new(format: :svg)
      assert config.format == :svg

      {:error, %Error{} = error} = Config.new(format: :foo)

      assert error.reason == :invalid_config
      assert error.message == "Expected format to be one of :html, :css, :svg, got: :foo"
    end
  end
end

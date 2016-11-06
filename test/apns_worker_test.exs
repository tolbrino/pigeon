defmodule Pigeon.APNSWorkerTest do
  use ExUnit.Case

  alias Pigeon.{APNSConfig, APNSWorker}

  describe "initialize_worker/1" do
    test "returns {:ok, config} on successful initialization" do
      config = :pigeon |> Application.get_env(:apns) |> Enum.random()
      result = config
                |> APNSConfig.ssl_config()
                |> APNSWorker.init()
      {:ok, %{
        apns_socket: _socket,
        mode: mode,
        config: config2,
        stream_id: stream_id,
        queue: _queue
      }} = result

      assert mode == :dev
      assert config2 == APNSConfig.ssl_config(config)
      assert stream_id == 1
    end

    test "returns {:stop, {:error, :invalid_config}} if certificate or key are invalid" do
      configs = Application.get_env(:pigeon, :apns)
      invalid_config = configs |> List.first() |> Map.put(:cert, "bad_cert.pem")

      result = invalid_config
                |> APNSConfig.ssl_config()
                |> APNSWorker.init()

      assert result == {:stop, {:error, :invalid_config}}
    end
  end

  describe "connect_socket_options/2" do
    test "returns valid socket options for given cert and key" do
      cert = {:cert, "cert.pem"}
      key = {:key, "key.pem"}
      actual = APNSConfig.connect_socket_options(cert, key)
      expected = [cert,
                  key,
                  {:password, ''},
                  {:packet, 0},
                  {:reuseaddr, true},
                  {:active, true},
                  :binary]

      assert actual == expected
    end

    test "includes {:port, 2197} if env apns_2197: true" do
      port = Application.get_env(:pigeon, :apns_2197)
      Application.put_env(:pigeon, :apns_2197, true)

      cert = {:cert, "cert.pem"}
      key = {:key, "key.pem"}
      config = APNSConfig.connect_socket_options(cert, key)

      assert Enum.any?(config, &(&1 == {:port, 2197}))

      Application.put_env(:pigeon, :apns_2197, port)
    end
  end
end

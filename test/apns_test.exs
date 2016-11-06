defmodule Pigeon.APNSTest do
  use ExUnit.Case

  test "push/2 sends a push notification" do
    config = :pigeon |> Application.get_env(:apns) |> Enum.random()
    n = Pigeon.APNS.Notification.new(test_message("push/2"), test_token, config.topic)
    assert Pigeon.APNS.push(config.id, n) == :ok
  end

  describe "push/2" do
    test "returns {:ok, notification} on successful push" do
      config = :pigeon |> Application.get_env(:apns) |> Enum.random()
      pid = self
      on_response = fn(x) -> send pid, x end

      n =
        "push/2 :ok"
        |> test_message()
        |> Pigeon.APNS.Notification.new(test_token, config.topic)

      assert Pigeon.APNS.push(config.id, n, on_response) == :ok
      assert_receive({:ok, _notif}, 5_000)
    end

    test "returns {:error, :bad_message_id, n} if apns-id is invalid" do
      config = :pigeon |> Application.get_env(:apns) |> Enum.random()
      pid = self
      on_response = fn(x) -> send pid, x end
      n =
        "push/2 :bad_message_id"
        |> test_message()
        |> Pigeon.APNS.Notification.new(test_token, config.topic, bad_id)

      assert Pigeon.APNS.push(config.id, n, on_response) == :ok
      assert_receive({:error, :bad_message_id, _n}, 5_000)
    end

    test "returns {:error, :bad_device_token, n} if token is invalid" do
      config = :pigeon |> Application.get_env(:apns) |> Enum.random()
      pid = self
      on_response = fn(x) -> send pid, x end
      n =
        "push/2 :bad_device_token"
        |> test_message()
        |> Pigeon.APNS.Notification.new(bad_token, config.topic)

      assert Pigeon.APNS.push(config.id, n, on_response) == :ok
      assert_receive({:error, :bad_device_token, _n}, 5_000)
    end

    test "returns {:error, :missing_topic, n} on missing topic for certs supporting mult topics" do
      config = :pigeon |> Application.get_env(:apns) |> Enum.random()
      token = Application.get_env(:pigeon, :valid_apns_token)
      pid = self
      on_response = fn(x) -> send pid, x end
      n =
        "push/2 :missing_topic"
        |> test_message()
        |> Pigeon.APNS.Notification.new(token)

      assert Pigeon.APNS.push(config.id, n, on_response) == :ok

      assert_receive({:error, :missing_topic, _n}, 5_000)
    end
  end

  defp test_message(msg), do: "#{DateTime.to_string(DateTime.utc_now())} - #{msg}"
  defp test_token, do: Application.get_env(:pigeon, :valid_apns_token)
  defp bad_token, do: "00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0"
  defp bad_id, do: "123e4567-e89b-12d3-a456-42665544000"

end

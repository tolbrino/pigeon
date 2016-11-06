defmodule Pigeon.SupervisorTest do
  use ExUnit.Case

  test "ensures supervisor starts all workers" do
    config = Application.get_env(:pigeon, :apns)
    assert length(config) == Supervisor.count_children(Pigeon.Supervisor).active
  end

  test "ensures supervisor skips invalid configurations" do
    :ok = Application.stop(:pigeon)
    config = Application.get_env(:pigeon, :apns)
    invalid_config = for c <- config, do: Map.put(c, :cert, nil)
    :ok = Application.put_env(:pigeon, :apns, invalid_config)
    :ok = Application.start(:pigeon)
    assert Supervisor.count_children(Pigeon.Supervisor).active == 0
    :ok = Application.stop(:pigeon)
    :ok = Application.put_env(:pigeon, :apns, config)
    :ok = Application.start(:pigeon)
  end

  describe "adm_configured?" do
    test "returns true if env :adm_client_id, and :adm_client_secret are set" do
      assert Supervisor.adm_configured?
    end

    test "returns false if not set" do
      client_id = Application.get_env(:pigeon, :adm_client_id)
      Application.put_env(:pigeon, :adm_client_id, nil)

      refute Supervisor.adm_configured?

      Application.put_env(:pigeon, :adm_client_id, client_id)
    end
  end

  test "valid_adm_config? returns true if proper Amazon ADM config keys present" do
    assert Supervisor.valid_adm_config?(Supervisor.adm_config)
  end

end

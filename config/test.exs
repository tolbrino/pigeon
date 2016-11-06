use Mix.Config

config :pigeon,
  gcm_key: System.get_env("GCM_KEY"),
  valid_gcm_reg_id: System.get_env("VALID_GCM_REG_ID"),
  valid_apns_token: System.get_env("VALID_APNS_TOKEN"),
  adm_client_id: System.get_env("ADM_OAUTH2_CLIENT_ID"),
  adm_client_secret: System.get_env("ADM_OAUTH2_CLIENT_SECRET"),
  apns: [
    %{
      cert: "cert.pem",
      id: :test_service,
      key: "key_unencrypted.pem",
      mode: :dev,
      topic: System.get_env("APNS_TOPIC"),
    },
  ]

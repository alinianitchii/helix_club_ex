defmodule MedicalCertificates.EventBus do
  def publish(event) do
    PubSub.publish({"medical_certificates_domain_events", event})
  end

  def subscribe(topic) do
    PubSub.subscribe(topic)
  end
end

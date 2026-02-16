# HelixClub

**HelixClub** is a work-in-progress thesis project exploring resilient, long-running business processes using **Domain-Driven Design** in Elixir.

The domain focuses on the operations of a sports club, particularly:
- member registration,
- time-sensitive membership activation,
- medical certificate validation,
- and payment processing.

## High level description

HelixClub is structured as an **Elixir umbrella application**, where each **subdomain** is implemented as a separate OTP application:

- **People** – manages people registries
- **Memberships** – handles membership types, membership life cycle and activation logic
- **Payments** – processes payments
- **PubSub** – a wrapper over `Phoenix.PubSub` used for domain event delivery


## Getting Started

Ensure a local **PostgreSQL** instance is running. The following databases must be available: `people_test`, `memberships_test`, and `payments_test`. The default credentials are:

- **User**: `postgres`
- **Password**: `postgres`

To set up the environment:

```bash
MIX_ENV=test
mix deps.get
mix ecto.create
mix ecto.migrate
iex -S mix
```

## TODO

The following tasks are planned:

- [ ] Abstract the write repository logic for reuse across contexts
- [ ] Create a shared projector abstraction for read model updates
- [ ] Refactor and standardize module names (currently too verbose and inconsistent)
- [ ] Define satisfying scaffolding
- [ ] Replace PubSub with GenServer for synchronous internal communication
- [ ] Define a strategy for asynchronous communication between bounded contexts (event bus, message broker, etc.)
- [ ] Implement Outbox pattern for reliable cross context communication
- [ ] Define release strategy
- [ ] Add secrets management

# Contributing

Development setup for working on this gem itself. If you're integrating `wulin_oauth` into a host app, see `AGENTS.md` and the README instead.

## Commands

```shell
bundle install
bundle exec rspec            # spec/**/*_spec.rb
bundle exec standardrb       # lint (must be clean before commit)
bundle exec standardrb --fix # auto-fix lint offenses
```

CI (`.gitlab-ci.yml`, Ruby 3.4) runs `standardrb` then `rspec` on every push.

## Structure

- `lib/wulin_oauth.rb` — gem entry point; `WulinOAuth.configuration` (lazy YAML load of `config/wulin_oauth.yml`) and the derived `oauth_identifier`/`access_token_url`/`new_authorization_url`/etc. readers
- `lib/wulin_oauth/engine.rb` — Rails::Engine; includes `WulinOAuth::AbstractController`/`WulinOAuth::Controller` into `ActionController::Base` via `ActiveSupport.on_load(:action_controller_base)`, applies `app/overrides` from Zeitwerk `on_load` callbacks, registers the user menu
- `lib/wulin_oauth/controller.rb` — the `current_user`/`current_user=` session accessor (which drops an expired token) and the `require_login`/`require_admin`/`on_login_page?` helpers
- `lib/wulin_oauth/app_request_signer.rb` — HMAC-signs the access token for calls to the provider's user API
- `lib/wulin_oauth/errors/wulin_oauth_authentication_error.rb` — raised by `User` when the provider rejects an access token
- `lib/wulin_oauth/wulin_master.rb` — the `user_menu` in `WulinMaster::AppBarMenu`; required by the engine only when `WulinMaster` is defined
- `lib/generators/wulin_oauth/config/` — `rails g wulin_oauth:config`, copies `config/wulin_oauth.yml`
- `app/models/user.rb` — the `User` proxy; not `ActiveRecord::Base`, backed by HTTParty calls to the provider
- `app/controllers/wulin_oauth/user_sessions_controller.rb` — `new`/`callback`/`destroy`, the login flow
- `app/overrides/` — `class_eval` extensions of `wulin_permits`' `UsersController`/`UserGrid` (invite/remove/reset-account and the user-management permissions). Ignored by Zeitwerk, and loaded each time Zeitwerk loads `UsersController` or `UserGrid` (`on_load`), never at boot — see AGENTS.md's Gotchas for why they aren't under `app/controllers`/`app/grids`
- `app/grids/invited_user_grid.rb`, `app/screens/add_user_screen.rb` — the "Invite User" modal's grid/screen
- `app/views/` — the login page and its layout; Haml
- `app/javascript/wulin_oauth.esm.js` — the ESM entry a host bundles with esbuild: the user-management grid actions and the login page's `connect.js`, both under `app/assets/javascripts`
- `app/assets/images/indicator.gif` — served by the host's Propshaft, which puts every engine's `app/assets/*` on its path
- `config/routes.rb` — `login`, `logout`, `oauth/callback`, `users` — merged straight into the host app's route set, no `mount`
- `spec/rails_helper.rb` — boots the smallest `Rails::Application` that gives real routing and controllers (no database — `User` isn't ActiveRecord), with a stand-in for the little of `WulinMaster` the gem touches (`spec/support/wulin_master.rb`); its root, `spec/fixtures/host_app`, stands in for `wulin_permits`' `UsersController`/`UserGrid`

## Conventions

- `WulinMaster` is an optional peer gem, not a dependency — code in lib/ that touches it is guarded with `defined?`. `wulin_permits` is needed for the overrides, but isn't declared in the gemspec either: the host app's Gemfile brings both.
- Ruby files start with `# frozen_string_literal: true`.
- `standardrb` is the formatter/linter; don't hand-format against a different style.
- Prefer the simplest solution: no speculative abstractions, no dead parameters, no code guarding against cases that can't happen.
- Don't rename `WulinOauth::UserSessionsController` or any other Rails-camelize-derived constant — see AGENTS.md's Gotchas.

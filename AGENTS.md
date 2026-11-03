# AGENTS.md

`wulin_oauth` is a Rails engine, never run standalone — it's always loaded into a wulin_master v3 host app (Rails 8, Propshaft, esbuild, dart-sass) alongside [`wulin_permits`](https://github.com/ekohe/wulin_permits), as the alternative to `wulin_auth`. This file is for agents working in a host app that consumes this gem. If you're developing the gem itself, see `CONTRIBUTING.md`.

## Wiring it into a host app

The wulin_master template (`WULIN_COMPONENTS=wulin_oauth,...`) does all of this; by hand:

- Gemfile — `wulin_master`, `wulin_permits`, `wulin_oauth`, in any order. `rails generate wulin_oauth:config` writes `config/wulin_oauth.yml`.
- `ApplicationController < ActionController::Base` must add `before_action :require_login` itself: this gem only defines `require_login`/`require_admin`, it never registers either as a callback. Anything that asks `User.current_user` (wulin_audit, for one) also needs a `before_action` calling `User.set_current_user(current_user)` — the gem keeps that thread-local but never sets it.
- The host app must **not** define its own `app/models/user.rb`. This gem's top-level `User` is an HTTParty-backed proxy for the provider's user API, not `ActiveRecord::Base`.
- Fill in every key of `config/wulin_oauth.yml` per environment — see the README's table. `redirect_uri` must match what's registered with the provider, or the exchange fails silently (`get_access_token` returns `nil`, the visitor is bounced back to `/login`).
- JavaScript: import `app/javascript/wulin_oauth.esm.js` into the app's esbuild bundle for the invite/remove/reset-account grid actions, and build a second entry for the login page (`layouts/session.html.haml` loads `wulin_oauth.js` and `wulin_oauth.css`, not the application bundle). The gem ships no compiled assets.
- Rescue `WulinOAuth::WulinOauthAuthenticationError` in `ApplicationController` if you want a friendly response instead of a 500 when the provider rejects an access token (`401`).

## Gotchas

- The controller class is `WulinOauth::UserSessionsController` — lowercase "auth", not `WulinOAuth`. Rails resolves the route's controller path (`wulin_oauth/user_sessions`) by camelizing each segment, which yields `WulinOauth`. The gem's own module (`WulinOAuth.configuration`, `WulinOAuth::Engine`, ...) is a separate, deliberately different constant.
- `WulinMaster` is optional in lib/ (`if defined? WulinMaster`), but the login layout (`WulinMaster.config.app_title`) and the callback's change-password menu wiring (`WulinMaster::AppBarMenu`) call it unguarded. Don't expect `/login` to work without it.
- `UsersController` and `UserGrid` are wulin_permits' classes. This gem extends them from `app/overrides/*_override.rb` with `class_eval`, applied whenever Zeitwerk loads either class (an `on_load` callback, so never at boot) and themselves ignored by Zeitwerk — don't add an `app/controllers/users_controller.rb` or `app/grids/user_grid.rb` to the gem: Zeitwerk would load only one of the two engines' files, depending on load order.
- The "Change Password" item in the user menu is added or removed in `WulinMaster::AppBarMenu`, a process-wide object, on every successful callback. In a multi-user process it reflects whoever signed in last.
- Login only happens through `callback`; `current_user` can be `nil` there if `get_access_token` fails (bad/expired code, provider down) — keep that branch working if you extend it.

## Verifying integration behavior

Claims about grid actions or menu wiring can be wrong if inferred from this repo alone — `app/grids`, `app/screens`, and `app/overrides/` are only half the picture; the other half is `wulin_permits`' own `UserGrid`/`UsersController` that the overrides extend, and whatever `wulin_master` actually does with `WulinMaster::AppBarMenu`/`WulinMaster::Grid`.

Before trusting an assumption about `wulin_permits`/`wulin_master` behavior, check it against a local checkout if one is available.

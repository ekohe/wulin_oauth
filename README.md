# WulinOAuth

OAuth2 "Connect" single sign-on for WulinMaster apps. Instead of storing
credentials itself, the host app redirects to a central resource host (the
"master" identity provider) for login, then exchanges the resulting
authorization code for an access token and a user profile.

## The Flow

1. `GET /login` renders a "Connect" button linking to the resource host's
   authorize URL (`WulinOAuth.new_authorization_url`).
2. The resource host authenticates the visitor and redirects back to
   `GET /oauth/callback?code=...`.
3. `WulinOauth::UserSessionsController#callback` exchanges the code for an
   access token (`User.get_access_token`), which also fetches the user's
   profile from the resource host and stores it in the session.
4. If the exchange fails (no code, no access token, no user id), the session
   is reset and the visitor is sent back to `/login`.
5. `GET /logout` resets the session and redirects to the resource host's own
   logout URL, so both the host app and the identity provider sign out.
6. When the provider issued the token with an `expires_in`, `current_user`
   is `nil` once it has passed and the session's user is dropped, so the next
   request that requires login goes back through the provider.

Because there's no local user table, `User` isn't an `ActiveRecord::Base`
model — it's a plain class that mirrors just enough of an AR-like interface
(`find`, `all`, `where`, `column_names`, ActiveModel naming) for WulinMaster's
grids to treat it like one, backed entirely by HTTParty calls to the resource
host's JSON API.

## Installation

Requires Ruby 3.2+, Rails 8.0+ and a wulin_master v3 host (Propshaft, esbuild,
dart-sass). The wulin_master template installs and wires it:
`WULIN_COMPONENTS=wulin_oauth,... rails new ... -m template.rb`. By hand, add
it alongside `wulin_permits`, whose user grid and controller it extends — in
any order:

```ruby
gem "wulin_permits", path: "vendor/gems/wulin_permits"
gem "wulin_oauth", path: "vendor/gems/wulin_oauth"
```

```shell
bundle install
bundle exec rails generate wulin_oauth:config
```

The generator writes `config/wulin_oauth.yml`. Fill in per environment:

| Key | Description |
|---|---|
| `authorize_uri` | Resource host URL that starts the OAuth authorization step |
| `access_token_uri` | Resource host URL to exchange a code for an access token |
| `resource_host` | Base URL used for every other API call (`/users.json`, `/invitations`, ...) |
| `change_password_uri` | Linked from the user menu's "Change Password" item |
| `logout_uri` | Resource host URL to also sign out of the identity provider |
| `redirect_uri` | Must match the callback URL registered with the resource host |
| `oauth_identifier` | OAuth client id |
| `oauth_secret` | OAuth client secret |

`WulinOAuth.configuration` reads the `Rails.env`-keyed block of this file
lazily and caches it; reassign `WulinOAuth.configuration=` in tests to avoid
touching the filesystem.

The engine's routes (`login`, `logout`, `oauth/callback`, and `users`) are
merged into your app's route set automatically — no `mount` line needed.

### Assets

The gem ships no compiled assets and no Sprockets manifests.

- Import `app/javascript/wulin_oauth.esm.js` into the app's esbuild bundle for
  the add/remove/reset-user grid actions.
- The login page's layout (`layout "session"`) loads `wulin_oauth.js` and
  `wulin_oauth.css` instead of the application bundle, so it renders before a
  session exists. Build both as entries of their own: the JavaScript imports
  jQuery and the same `wulin_oauth.esm.js`; the stylesheet is the app's
  materialize theme.

### What your host app must provide

- A top-level `ApplicationController` (as every Rails app has) — WulinOAuth's
  controllers inherit from it. It must itself add
  `before_action :require_login` (see Controller Helpers below) — this gem
  only defines the method, it doesn't register it as a callback anywhere,
  and `UserSessionsController` skips it by name on `new`/`callback`.
- A `before_action` that calls `User.set_current_user(current_user)`, after
  `require_login`. The provider API calls (`User.all`, `User.invite`, ...)
  and anything else without a controller at hand (wulin_audit, for one)
  read the user from that thread-local, which the gem never sets itself.
- A `User` model — this gem defines one. Don't also define your own
  `app/models/user.rb`; the two would collide over the same top-level
  constant.
- `WulinMaster::AppBarMenu` and `WulinMaster.config.app_title` — unlike the
  grid/screen extras, the login page's own layout and the callback's
  change-password menu wiring call `WulinMaster` directly, with no
  `defined?` guard. In practice this gem is never loaded without
  WulinMaster, but if you ever try, `/login` itself will raise a
  `NameError`.

## Controller Helpers

Mixed into every `ActionController::Base` subclass:

- `current_user` / `current_user=` — reads/writes the session-backed `User`
- `require_login` / `require_admin` — plain methods, not `before_action`s;
  your `ApplicationController` registers them itself
  (`before_action :require_login`), and redirects to `/login` (HTML) or
  renders `{error: :not_authorized}` (JSON) when unmet
- `on_login_page?` — true on the login page, useful to avoid
  redirect loops in a shared `before_action`

## Errors

`User.find_by_ids` and `User.to_a` raise
`WulinOAuth::WulinOauthAuthenticationError` when the resource host responds
`401` — the session's access token has expired or been revoked. Rescue it in
your own `ApplicationController` (e.g. `rescue_from` redirecting to
`/login`); this gem doesn't rescue it itself.

## WulinMaster Integration

If [WulinMaster](https://github.com/ekohe/wulin_master) is loaded:

- Adds a `user_menu` to `WulinMaster::AppBarMenu` (account icon, current
  user's email) with "Change Password" and "Logout" items, whatever the
  Gemfile order. The callback
  action adds/removes "Change Password" per-request based on
  `current_user.can_change_password?`.
- `UserGrid` (from [wulin_permits](https://github.com/ekohe/wulin_permits))
  gets `add_user`/`remove_user`/`reset_account` toolbar actions, plus
  `a_password`/`welcome_email_sent_at` columns.
- `UsersController` (also from `wulin_permits`) gets `invite`, `destroy`,
  `create`, and `send_mail` actions wired to the resource host's invitation
  API.
- `AddUserScreen` at `/users?uninvited_users_only=true` lists not-yet-invited
  users for the invite modal.

## Contributing

Jimmy, Xuhao and Maxime Guilbot from [Ekohe](https://ekohe.com).

## License

WulinOAuth is released under the MIT license.

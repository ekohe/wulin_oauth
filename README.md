# WulinOAuth

Rails engine for [`wulin_master`](https://gitlab.ekohe.com/ekohe/wulin/wulin_master) apps. It signs users in through an OAuth provider (mima in the hbs apps) and adds user invite, dismiss and reset actions.

## Installation

Add the submodule at `vendor/gems/wulin_oauth` on `develop`, then add the gem to the `Gemfile`:

```ruby
gem "wulin_oauth", path: "vendor/gems/wulin_oauth"
```

The invite and dismiss actions are based on `wulin_permits`. Put `wulin_oauth` below it in the `Gemfile`.

Then:

```shell
bundle install
bundle exec rails g wulin_oauth:config
```

The generator creates `config/wulin_oauth.yml`. Set `authorize_uri`, `access_token_uri`, `resource_host`, `change_password_uri`, `logout_uri`, `redirect_uri`, `oauth_identifier` and `oauth_secret` for each environment.

## Usage

The engine adds the routes `/login`, `/logout`, `/oauth/callback` and `users`.

Load the JavaScript in the app bundle. The app's login page (`layouts/session.html.haml`) needs its own entry that also loads jQuery. The hbs apps use `app/javascript/wulin_oauth.js`:

```js
import "../../vendor/gems/wulin_oauth/app/javascript/wulin_oauth.esm.js"
```

When `WulinMaster` is defined, the gem adds a user menu with Change Password and Logout.

The `UsersController` that handles the requests must come from `wulin_oauth`. If you get `undefined method errors for #<User>`, check that.

## Development

Ruby 4.0.9, Rails 8.1. The gem has no test suite. CI builds the gem:

```shell
bundle install
gem build wulin_oauth.gemspec
```

## License

MIT, see `LICENSE`.

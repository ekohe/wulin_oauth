# AGENTS.md

`wulin_oauth` is a Rails engine. It always loads into a host app next to `wulin_master`. The hbs apps (ceres, atlas, cruise, olatu and others) vendor it at `vendor/gems/wulin_oauth`.

## Wiring it into a host app

- Gemfile, `config/wulin_oauth.yml` and JavaScript: see the README.
- The config is read from `config/wulin_oauth.yml` under the key of `Rails.env` (`WulinOAuth.configuration`).
- Sign-in goes to `authorize_uri` and comes back to `/oauth/callback`. `/login` renders a page that links to the provider.
- ceres loads the gem JavaScript twice: `app/javascript/application.js` for the main bundle, and `app/javascript/wulin_oauth.js` for the login page, which does not load the main bundle. That entry already exists in the apps. Do not add another one.
- ceres requires the gem `User` model in `config/initializers/user.rb`.

## Gotchas

- `app/models/user.rb` calls the provider API (`resource_host`) through HTTParty for token exchange, user lookup, invite, dismiss and reset.
- `lib/wulin_oauth.rb` adds the user menu only when `WulinMaster` is defined.
- The gem has no test suite. The old `test/` directory loaded files that do not exist and was removed.

## Commands

```shell
export PATH=/opt/homebrew/Cellar/ruby/4.0.10/bin:$PATH
bundle install
gem build wulin_oauth.gemspec
```

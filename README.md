# WulinOAuth

## How to Use

- Put 'gem wulin_oauth' to your Gemfile:

  ```shell
  gem `wulin_oauth`
  ```

  **_Hint_(very significant)**: As we add the invite/dismiss user function(add_user/remove_user action), which is based on `wulin_permits`. So we have to put the `wulin_oauth` under `wulin_permits` in the `Gemfile`, for example:

  ```ruby
  gem "wulin_permits", path: "vendor/gems/wulin_permits"
  gem "wulin_oauth", path: "vendor/gems/wulin_oauth"
  ```

  Besides, we added the `WulinMaster.actions.AddUser`, so we have to import the `wulin_oauth.js` into your project `app/assets/javascripts/application.js`, for example:

  ```js
  //= require 'master/master.js'
  //= require 'wulin_permits.js'
  //= require 'wulin_oauth.js'
  ```

  you'd better put `wulin_oauth.js` under `master/master.js` to avoid unnecessary trouble.

- Run bundler command to install the gem:

  ```shell
  bundle install
  ```

- After you install wulin_oauth gem, you need run the generator:

  ```shell
  bundle exec rails g wulin_oauth:migration
  ```

  It will generator `db/migrate/<timestamp>_create_users.rb` migrate file to your app

  Run with **_bundle exec rails g_** for get generator list.

- Don't forget to run the db:migrate rake command:

  ```shell
  bundle exec rake db:migrate
  ```

## Contributing

Jimmy, Xuhao and Maxime Guilbot from Ekohe, inc.

## License

WulinOAuth is released under the MIT license.

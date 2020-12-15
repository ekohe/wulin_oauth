# WulinOAuth

## How to Use

- Put 'gem wulin_oauth' to your Gemfile:

  ```shell
  gem wulin_oauth
  ```

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

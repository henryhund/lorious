## Dependencies

* Ruby 2.0 (Install using [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv))
* PostgreSQL 9.2+
* Solr Sunspot added under development env in Gemfile, run bundle
* Redis - Intall using brew utility
```bash
brew install redis
```
* V8 (this will probably be compiled automatically during `bundle install` if you are missing it)

## Quick Start Instructions

0. Make sure the dependencies above are installed.

1. Clone the repository.

2. Install gems:
```bash
bundle install
```
3. Install Redis

4. Copy and personalize your `database.yml` file:
```bash
cp config/{database.yml.sample,database.yml}
```

5. Copy and personalize your `application.yml` file:
```bash
cp config/{application.yml.sample,application.yml}
```
   This file defines environment variables that will be used for configuring email, Facebook app keys, and so on. Always use this file for defining environment variables instead of hard-coding secret information inside the repository. When you add a variable here, also add a corresponding dummy variable in the `application.yml.sample` file so that developers know they need to fill it in.

6. Create your databases:
```bash
rake db:reset && RAILS_ENV=test rake db:reset
```
7. Run the test suite:
```bash
bundle exec rspec
```
Make sure that everything passes before proceeding. If it doesn't, then chances are that you either are missing a dependency, or that you did not fill in a required value in `application.yml`.

8. Seed the settings into the development environment.
```bash
rake db:seed
```

9. Open the Rails console and create yourself a regular user and an admin user.

```bash
rails c
```

```ruby
User.create!(
  email: 'user@example.com', first_name: 'Mister', last_name: 'User', password: '12345678', admin: false)
User.create!(
  email: 'admin@example.com', first_name: 'Mister', last_name: 'Admin', password: '12345678', admin: true)
```

or Create an invite and using the generated oauth token paste the following url into the browser to get redirected to 
a user creation wizard. 

```ruby
"/users/auth/google_oauth2?invite_token=" + invite.token
```

10. Run the server:
```bash
rails s
```

11. Open `http://localhost:3000/admin` and log in with your Admin account credentials to see the Admin dashboard.

## Setting up Google+ Hangout Api

0. Go to [Google API Console](https://code.google.com/apis/console) and create a google developer account. 
1. Register for a Google + Hangout API and in the Application URL enter the url of the website followed by the Google Hangout App XML file. for eg:  http://lorious-dev.herokuapp.com/ExpertHangout.xml.
2. Make the application type an Extension.
3. Enter a nage for the Application and enter urls for the Terms of Service, Policy etc.
4. Check "Make you app public" to make the application public. (Note: a web developer charge of $5 is required) .


## Setting up an OAuth account for social media.
0. These steps are common accross all the platforms. Please read this to get detail information on how to setup an app using social media site's developer portal and obtain the api keys to enter in the application.yml file.
http://railscasts.com/episodes/360-facebook-authentication?view=asciicast





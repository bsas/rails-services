# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails_app_v2_session',
  :secret      => '5436991dc19aef6a4cb2b3b152711b486738ba5a34531a749b7887ad965d3c736157ee6e8571e4aeb202d6e018a1929cb3c6a20e84045a60d2a6095eaea884af'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wicked_start_session',
  :secret      => 'e821ea518188855c88fb78672a0cc012af0f0215f1a9f0cecffaa62ff398aa00f665a1ed71309e534e53c5511ae129390253e9e1423b9f32390f43533e738362'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

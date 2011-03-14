#!/usr/bin/env ruby

# Our reCAPTCHA public key.
RECAPTCHA_PUBLIC_KEY = 'example reCAPTCHA public key'
RECAPTCHA_PRIVATE_KEY = 'example reCAPTCHA private key'

# Information about the server we should join.
SERVER = {
	host: 'example.net',
	port: 6697,
	ssl: true,
	nick: 'recaptcha_bot'
}

# A list of channels we should protect. Note that we need to be able to invite
# people to these channels in order to function properly. (Usually, this means
# we need +o or +h (oper or half oper, respectively).)
CHANNELS = ['#test']

# This is the URL we refer users who KNOCK on our channels to. Sinatra should be
# listening here.
ACCESS_URL = 'http://example.net/'

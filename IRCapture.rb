#!/usr/bin/env ruby
require 'sinatra'
require 'thread'
require 'net/http'
require 'cinch'
require_relative 'config'

# Use HTTP Keep-alive so we don't open a gazillion connections.
def verifier_session
	if $recaptcha_verifier_session and $recaptcha_verifier_session.active?
		$recaptcha_verifier_session
	else
		$recaptcha_verifier_session = Net::HTTP.start( 'www.google.com', 443,
		                                               use_ssl: true )
	end
end

bot = Cinch::Bot.new do
	# There's probably a way to make this a real method, but I can't find it, so
	# this will do for now.
	send_captcha = lambda do |user, channel|
		info_fragment = URI.encode_www_form(
			server: SERVER[:host],
			nick: user,
			channel: channel
		)
		s = "You must solve the CAPTCHA at #{ACCESS_URL}?#{info_fragment} to " \
				"join #{channel}."
		User(user).msg(s)
	end

	configure do |c|
		c.server = SERVER[:host]
		c.port = SERVER[:port]
		c.ssl = SERVER[:ssl]
		c.nick = SERVER[:nick]
		c.channels = CHANNELS
	end

	on :'710' do |knock|
		# Cinch doesn't parse the user properly.
		user = knock.params[2].split('!')[0]

		send_captcha[user, knock.channel]
	end

	on :invite do |invite|
		# We might not be able to access a channel until we're invited to it.
		if CHANNELS.include? invite.channel
			invite.channel.join()
		end
	end
end

Thread.new{ bot.start }

get '/' do
	erb :index, {},
		server: params[:server],
		nick: params[:nick],
		channel: params[:channel],
		pubkey: RECAPTCHA_PUBLIC_KEY
end

get '/request_invite.html' do
	post_data = URI.encode_www_form(
		privatekey: RECAPTCHA_PRIVATE_KEY,
		remoteip: request.ip,
		challenge: params[:recaptcha_challenge_field],
		response: params[:recaptcha_response_field]
	)
	response = verifier_session.post('/recaptcha/api/verify', post_data)

	success, reason = response.body.split("\n")

	if success == 'true'
		success = true
		bot.Channel(params[:channel]).invite(params[:nick])
	elsif reason == 'incorrect-captcha-sol'
		success = false
	else
		raise "the reCAPTCHA API returned an error: #{reason}"
	end

	erb :request_invite, {},
		success: success,
		server: params[:server],
		channel: params[:channel]
end

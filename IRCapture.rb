#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
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

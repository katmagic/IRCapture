IRCapture
=========

IRCapture allows one to protect an IRC channel with a CAPTCHA. *It is still in
a pre-alpha state*, so don't expect it to work properly.

Usage
-----
Because IRCapture uses [reCAPTCHA](https://www.google.com/recaptcha), you need
to have a Google account in order to set it up. Once you've registered for
reCAPTCHA, you must specify your public and private reCAPTCHA keys in config.rb.

Now you need to set up information about the IRC server we should join, the nick
we should use, and the channels we should join. These should be self
explanatory. Note that the channels IRCapture should protect should either be
empty when we join, in which case IRCapture will automatically make it
invitation-only; or else one must make the channel invitation-only, invite us
into it, and give us operator status manually. (Though not necessarily in that
order).

IRCapture utilizes [Sinatra](http://www.sinatrarb.com/), which will
automatically bind to TCP port 4567. You must configure a URL at which we can be
accessed in `ACCESS_URL`. If, for example, the server's [external] domain name
is example.net, one would set `ACCESS_URL` to `http://example.net:4567/`.

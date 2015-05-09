Promise = require 'bluebird'
url = require 'url'
https = require 'https'
request = require 'request'

YO_USERNAME = ""
YO_API_TOKEN = ""

TOKEN = ""
NAMESPACE_ID = ""

getCursor = ->
  now = Math.round(new Date().getTime() / 1000.0)
  new Promise (resolve, reject) ->
    options =
      method: 'POST'
      url: "https://api.nylas.com/n/#{NAMESPACE_ID}/delta/generate_cursor"
      json: true
      auth: {user: TOKEN, pass: ""}
      body: start: now

    request options, (error, response, body) ->
      if error then reject(error)
      else resolve(body.cursor)

yo = (to=YO_USERNAME) ->
  options =
    headers: {'content-type' : 'application/x-www-form-urlencoded'}
    method: "POST", url: "http://api.justyo.co/yo/"
    body: "api_token=#{YO_API_TOKEN}&username=#{to}"
  request options, (error, reponse, body) -> console.log "YO", body

console.log "---> Yo got mail?"
getCursor().then (cursor) ->
  console.log "---> Waiting for email"
  streamURL = "https://api.nylas.com/n/#{NAMESPACE_ID}/delta/streaming?cursor=#{cursor}&exclude_types=contact,event,file,tag,thread" # only message types
  options = url.parse(streamURL)
  options.auth = "#{TOKEN}:"

  req = https.request options, (res) ->
    res.setEncoding('utf8')
    res.on 'data', (chunk={}) =>
      from = JSON.parse(chunk).attributes?.from?[0]?.email
      console.log "Yo got mail from #{from}!"
      yo(YO_USERNAME)
  req.write("1")

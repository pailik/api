local json = require "cjson"

local args = ngx.req.get_uri_args()

if "111" ~= args['client_id'] then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say('{"error":"invalid_grant","error_description":"Code is expired."}')
    ngx.exit(ngx.status)
end

if "secret" ~= args['client_secret'] then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say('{"error":"invalid_grant","error_description":"Code is expired."}')
    ngx.exit(ngx.status)
end

if "kubikvest" ~= args['redirect_uri'] then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say('{"error":"invalid_grant","error_description":"Code is expired."}')
    ngx.exit(ngx.status)
end

if "222" ~= args['code'] then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say('{"error":"invalid_grant","error_description":"Code is expired."}')
    ngx.exit(ngx.status)
end

local jsonError, jsonData = pcall(json.encode, {
    access_token  = "533bacf01e11f55b536a565b57531ac114461ae8736d6506a3",
    expires_in    = 43200,
    user_id       = 66748,
})

if not jsonError then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("json encode fail")
    ngx.exit(ngx.status)
end

ngx.status = ngx.HTTP_OK
ngx.say(jsonData)
ngx.exit(ngx.status)

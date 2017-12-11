-- This is zrwoxy, a trolling HTTP proxy.
-- Manipulate HTTP traffic and HTML content using Nginx and Lua.

-- HTTP and HTML libraries
-- https://github.com/pintsized/lua-resty-http
-- https://github.com/craigbarnes/lua-gumbo
local http = require("resty.http")
local gumbo = require("gumbo")

-- Logging
--ngx.log(ngx.INFO, "zrwoxy processing HTTP request")


-- Read request body and request URI
ngx.req.read_body()
local body = ngx.req.get_body_data()
local uri = ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri


-- *Request* body manipulation would be super evil
-- if body ~= nil then
--     body = body:gsub("1996","2017")
-- end


-- Proxy HTTP request
local httpc = http.new()
local res, err = httpc:request_uri(uri, {
    method = ngx.var.request_method,
    headers = ngx.req.get_headers(),
    body = body,
})

if not res then
    ngx.say("Request failed: ", err)
    return
end


-- Propagate response status
ngx.status = res.status

-- Propagate response headers
for key, value in pairs(res.headers) do
    ngx.header[key] = value
end


-- Response body manipulation, only for HTML
-- TODO: Also handle gzipped responses by deflating them
local is_html = ngx.header["Content-Type"] and string.find(ngx.header["Content-Type"], "text/html", 1, true) ~= nil
local is_gzip = ngx.header["Content-Encoding"] == "gzip"
if is_html and not is_gzip then

    -- Logging
    ngx.log(ngx.INFO, "zrwoxy manipulating HTTP response")

    -- Parse HTML into DOM
    local document = assert(gumbo.parse(res.body))

    -- Traverse DOM and manipulate text nodes
    for node in document.body:walk() do
        -- Node.TEXT_NODE == 3
        -- See also https://craigbarnes.gitlab.io/lua-gumbo/#node
        if node.nodeType == 3 then

            -- Verbatim string replacement
            node.data = node.data:gsub("1996", "2018")

            -- Remove vowels
            node.data = node.data:gsub("[AEIOUaeiou]", "")

        end
    end

    -- Inject CSS style as last element into <head></head>
    local css = "body { background: red; font-style: italic; font-size: larger; }"
    local style = document:createElement("style")
    local content = document:createTextNode(css)
    style:appendChild(content)
    document.head:appendChild(style)

    -- Serialize DOM to HTML
    local body = document:serialize()

    -- When manipulating the response body, we should properly account
    -- for the changed Content-Length. Otherwise, clients will stall
    -- on receiving the response if the manipulated response payload
    -- is shorter than before.
    ngx.header["Content-Length"] = string.len(body)

    -- If set, remove the "Transfer-Encoding: chunked" header as
    -- the response body was manipulated and will get propagated 1:1.
    if ngx.header["Transfer-Encoding"] == "chunked" then
        ngx.header["Transfer-Encoding"] = nil
    end

    -- Propagate modified response body
    ngx.say(body)

else

    -- Propagate verbatim response
    ngx.say(res.body)

end

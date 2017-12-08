-- This is zrwoxy, a trolling HTTP proxy.
-- Manipulate HTTP traffic and HTML content using Nginx and Lua.

-- HTTP and HTML libraries
-- https://github.com/pintsized/lua-resty-http
-- https://github.com/craigbarnes/lua-gumbo
local http = require("resty.http")
local gumbo = require("gumbo")


-- Read request body and request URI
ngx.req.read_body()
local body = ngx.req.get_body_data()
local uri = ngx.var.scheme .. '://' .. ngx.var.host .. ngx.var.request_uri


-- *Request* body manipulation would be super evil
-- if body ~= nil then
--     body = body:gsub("1996","2017")
-- end


-- Proxy HTTP request
local httpc = http.new()
local res, err = httpc:request_uri(uri, {
    method = ngx.var.request_method,
    body = body,
    headers = ngx.req.get_headers(),
})

if not res then
    ngx.say("failed to request: ", err)
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
local is_html = string.find(ngx.header["Content-Type"], "text/html", 1, true) ~= nil
local is_gzip = ngx.header["Content-Encoding"] == "gzip"
if is_html and not is_gzip then

    -- When manipulating the response body, we should reset the Content-Length.
    -- Otherwise, clients would stall on receiving the response.
    ngx.header["Content-Length"] = nil

    -- Parse HTML into DOM
    local document = assert(gumbo.parse(res.body))

    -- Traverse DOM and manipulate text nodes
    for node in document.body:walk() do
        -- Node.TEXT_NODE == 3
        -- See also https://craigbarnes.gitlab.io/lua-gumbo/#node
        if node.nodeType == 3 then
    	   node.data = node.data:gsub("1996", "2018")
        end
    end

    -- Inject CSS style as last element into <head></head>
    local css = "body { background: red; font-style: italic; font-size: x-large; }"
    local style = document:createElement("style")
    local content = document:createTextNode(css)
    style:appendChild(content)
    document.head:appendChild(style)

    -- Propagate modified response
    ngx.say(document:serialize())

else

    -- Propagate verbatim response
    ngx.say(res.body)

end

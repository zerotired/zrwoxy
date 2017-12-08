
-- ngx.say("hello zrw")



      -- For simple singleshot requests, use the URI interface.
      ngx.req.read_body()
      local body = ngx.req.get_body_data()
      local uri = ngx.var.scheme .. '://' .. ngx.var.host .. ngx.var.request_uri
      
	


	local htmlparser = require("htmlparser")



      local http = require "resty.http"
      local httpc = http.new()
      local res, err = httpc:request_uri(uri, {
        method = ngx.var.request_method,
	body = body,
	headers = ngx.req.get_headers(),

        --headers = {
        --  ["Content-Type"] = "application/x-www-form-urlencoded",
        --}
      })

      if not res then
        ngx.say("failed to request: ", err)
        return
      end

      -- In this simple form, there is no manual connection step, so the body is read
      -- all in one go, including any trailers, and the connection closed or keptalive
      -- for you.

      ngx.status = res.status

      for key,value in pairs(res.headers) do
	ngx.header[key] = value
      end

if res.body ~= nil then
--	res.body = res.body:gsub("1996","2017")
end

local is_gzip = ngx.header["Content-Encoding"] == "gzip"
if not is_gzip and string.find(ngx.header["Content-Type"], "text/html", 1, true) ~= nil then

	ngx.header["Content-Length"] = nil

	local gumbo = require "gumbo"
	local document = assert(gumbo.parse(res.body))

	for node in document.body:walk() do
	    -- if node.nodeType == gumbo.Node.TEXT_NODE then
	    if node.nodeType == 3 then 
		node.data = node.data:gsub("1996", "2018")
	    end
	end

        local style = document:createElement("style")
        local content = document:createTextNode("body { background: green; font-style: italic ; font-size: x-large;}")
        style:appendChild(content)
        document.head:appendChild(style)

	ngx.say(document:serialize())
else
	ngx.say(res.body)
end


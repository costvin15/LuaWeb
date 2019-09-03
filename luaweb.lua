local luaweb = {
    routes = {}
}

function luaweb:get(route, callback)
    self.routes[route] = callback()
end

local function manipulate_request(request)
    local request_table = {}
    local headers = {}
    for token in string.gmatch(request, "([^\n]+)") do
        table.insert(request_table, token)
    end
    for i = 2, #request_table do
        local table_aux = {}
        for token in string.gmatch(request_table[i], "([^%s]+)") do
            table.insert(table_aux, token)
        end
        headers[table_aux[1]] = table_aux[2]
    end
    local http_verb_table = {}
    for token in string.gmatch(request_table[1], "([^%s]+)") do
        table.insert(http_verb_table, token)
    end
    return http_verb_table, headers
end

local function get_mime_type(filename)
    extension = ""
    for token in string.gmatch(filename, "([^.%s]+)") do
        extension = token
    end
    
    if (extension == "css") then
        return "text/css"
    elseif (extension == "jpeg") then
        return "image/jpeg"
    end
    return "text/html"
end

local function get_response(content, headers, filename)
    return [[
HTTP/1.1 200 OK
Date: ]] .. os.date("%a, %d %b %Y %X GMT") .. [[

Accept-Ranges: bytes
Content-Length: ]] .. #content .. [[

Connection: close
Content-Type: ]] .. get_mime_type(filename) .. [[


]] .. content
end

local function get_request(client)
    local request = ""

    while 1 do
        local line = client:receive("*l")
        if (line ~= "") then
            request = request .. line .. "\n"
        else
            break
        end
    end

    return request
end

local function print_table(table)
    for i, v in ipairs(table) do
        print(i, v)
    end
end

function luaweb:listen(domain, port)
    local socket = require("socket")
    local master = socket.tcp()
    master:bind(domain, port)
    master:listen()

    print(master:getsockname())    

    while 1 do
        local client = master:accept()
        local request = get_request(client)
        if (request ~= nil) then
            request, headers = manipulate_request(request)
            if (self.routes[request[2]] == nil) then
                response = ""
                -- local file = io.open("." .. request[2])
                -- if (file) then file:close() end
                -- if (file ~= nil) then
                --     for line in io.lines(string.sub(request[2], 2, #request[2])) do
                --         response = response .. line
                --     end
                -- else
                --     response = "Not found"
                -- end
                local file = io.open("." .. request[2], "rb")
                if (file ~= nil) then
                    response = response .. file:read("*all")
                else
                    response = "Not found"
                end
            else
                response = self.routes[request[2]]
            end
        else
            response = "Internal server error"
        end
        client:send(get_response(response, headers, request[2]))
    end
end

return luaweb
local luaweb = require("luaweb")

luaweb:get("/", function()
    return "Raiz do projeto!"
end)

luaweb:get("/hello", function()
    local response = ""
    for line in io.lines("index.html") do
        response = response .. line
    end
    return response
end)

luaweb:listen("*", 8080)
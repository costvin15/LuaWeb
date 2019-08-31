local luaweb = require("luaweb")

luaweb:get("/", function()
    return "Raiz do projeto!"
end)

luaweb:get("/hello", function()
    return "<h1>Hello, World!<h1>"
end)

luaweb:listen("*", 8080)
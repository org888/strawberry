local response = require "framework.response"

local UnittestController = {}

function UnittestController:mysqlclient()
    local mysql_client = require "framework.db.mysql.client"
    local client = mysql_client:new()
    if not client:connect({
        host = "127.0.0.1",
        user="root",
        password = "",
        database = "fruit",
        timeout = 2000,
    }) then
        return
    end
    local res = client:query("select * from user")
    return response:new():send_json(res)
end

function UnittestController:mysqlreplica_master()
    local mysql_replica = require "framework.db.mysql.replica"
    local replica = mysql_replica:instance("activity")
    if not replica then
        return "invalid mysql db specified"
    end
    local res = replica:master():query("select * from user")
    return response:new():send_json(res)
end

function UnittestController:mysqlreplica_slave()
    local mysql_replica = require "framework.db.mysql.replica"
    local replica = mysql_replica:instance("activity")
    if not replica then
        return "invalid mysql db specified"
    end
    local res = replica:slave():query("select * from user")
    return response:new():send_json(res)
end

function UnittestController:redisclient()
    local redis_client = require "framework.db.redis.client"
    local client = redis_client:new()
    if not client:connect({
        host = "127.0.0.1",
        timeout = 2000,
    }) then
        return
    end
    res = client:query("get", "dog")
    return response:new():send_json(res)
end

function UnittestController:flexihash()
    local util_flexihash = require "framework.utils.flexihash"
    local flexihash = util_flexihash:instance()
    local targets = {
        "127.0.0.1:6379",
        "127.0.0.1:6380",
        "127.0.0.1:6381",
    }
    local freq = {}
    for k, target in pairs(targets) do
        flexihash:add_target(target)
        freq[target] = 0
    end

    for i = 1, 1000 do
        local str = self:_random_string(3)
        local target = flexihash:lookup(str)
        freq[target] = freq[target] + 1
    end

    return response:new():send_json(freq)
end

function UnittestController:crc32()
    local CRC = require "framework.libs.hasher.crc32"
    return tostring(CRC.crc32('aa'))
end

function UnittestController:rediscluster()
    local redis_cluster = require "framework.db.redis.cluster"
    local cluster = redis_cluster:instance()
    if cluster then
        return response:new():send_json(cluster:query("get", "dog"))
    else
        return "invalid redis cluster specified"
    end
end

function UnittestController:_random_string(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

function UnittestController:error()
    return response:new():error(404, "Resource not found")
end

function UnittestController:test()
    local s = require("vanilla.v.libs.http"):new()
    local res = s:get("http://www.baidu.com",'GET','',{},0)

    return res.body
end

return UnittestController
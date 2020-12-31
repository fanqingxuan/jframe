local Application = require("libs.application")


local application = Application:new()

application:parse() -- 解析控制器、动作

application:check() --检查控制器、动作

application:run() -- 执行控制器、动作


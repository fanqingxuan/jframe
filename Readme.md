用openresty搭建的一个简易web api框架，方便之后用的时候快速生成项目结构

### 目录结构

结构供包含config、controller、libs、model四个目录

- config

  配置文件目录，用于app、redis、database相关的配置

  - app应用相关

  ```lua
  return {
  	default_controller = 'home', -- 默认控制器
  	default_action	   = 'index', -- 默认方法
  }
  ```

  - 数据库相关

  ```lua
  local mysql_config = {
      timeout = 5000,
      connect_config = {
          host = "127.0.0.1",
          port = 3306,
          database = "demo",
          user = "root",
          password = "a12345",
          max_packet_size = 1024 * 1024
      },
      pool_config = {
          max_idle_timeout = 20000, -- 20s
          pool_size = 50 -- connection pool size
      }
  }
  ```

  - redis配置

  ```lua
  return {
      host = "127.0.0.1", -- redis host
      port = 6379, -- the port
      max_idle_timeout = 60000, -- max idle time
      pool_size = 1000, -- pool size
      timeout = 1000, -- timeout time
      db_index= 2, -- database index
      
  }
  ```

- libs目录

  libs目录下面的公共的模块库，包括redis、db、request、response等

- controller目录

  这是控制器目录，里面有一个封装了一个基类Base.lua,业务控制器继承这个即可，基本的业务控制器代码如下

  ```lua
  -- home.lua
  local Base = require("controller.base")
  
  local Home = Base:extend()
  
  function Home:index() 
      self:json({data={}})
  end
  ```

  上面的代码就实现了一个控制器，访问路径hostname://home/index即可请求index方法,请求的url规则是hostname+controller文件夹下的文件名+/+文件中的方法名**(注意一定要继承Base模块)**

  controller里面提供了几个基本属性

  - self.request获取请求相关参数，如self.request.query.xx获取get参数，self.request.body.xx获取post参数，self.request.headers.xx获取header参数等

  - self.response输出响应结果，主要有self.response:json()返回data结果，以及self.response:redirect()跳转,self.response.get_body()获取响应结果等

    为了方便开发，在Base里面封装了response，提供了self:json(),self:error(code,message)两个快捷方法

    ```lua
    self:json({data=self.redis:get("test")}) --返回结果设置data
    self:error(2,"获取数据失败") --返回结果设置错误码，错误消息
    ```

    返回的结构包含data,code,message字段

    ```lua
    {"data":{"data":["BBBBB","B","AAAAA","A","BBBBB","B","AAAAA","A"]},"message":"","code":"获取成功"}
    ```

  - self.redis可以使用redis，包含self.redis:set,self.redis:get,self.redis:hset,self.redis:hget等等，具体可以使用的函数可以参考**libs/redis.lua**文件的15到72行

  - self.controller获取当前控制器名称

  - self.action获取当前action操作名称

- model目录

  模型相关，为了便于操作，也封装了一个Base基类，业务model只需要继承即可

  ```lua
  -- good.lua
  local Base = require "model.base"
  
  local Good = Base:extend() --继承Base
  
  return Good("test",'lgid') --第一个参数表名称,第二个参数是表对应的主键(默认为id)
  ```

  Base.lua封装的基类提供了单表增删改查的方法

  - create(data)添加记录
  - delete(id)删除记录
  - update(data,id)修改记录
  - get()、all()过滤记录
  - where()过滤条件方法
  - columns()设置查找哪些列的方法
  - orderby()设置排序的方法
  - count()查找数据总条数的方法

  同时Base.lua也提供了一个方法用于自定义执行sql的方法，方便复杂查询

  - query()

### 快速开始

- nginx.conf添加类似如下代码

  ```she
  worker_processes  1;
  error_log logs/error.log;
  events {
      worker_connections 1024;
  }
  http {
  
      lua_package_path 'E:/openresty/demo/src/?.lua;;';
      server {
          charset utf-8;        
          listen 8080;
          
          location = /favicon.ico {
            log_not_found off;#关闭日志
            access_log off;#不记录在access.log
          }
  
          location / {
              default_type text/html;
              content_by_lua_file "E:/openresty/demo/src/main.lua";
          }
      }
  }
  ```

- 添加控制器

  在controller目录添加user.lua

  ```lua
  local Base = require("controller.base")
  
  local User = Base:extend()
  
  function User:index() 
      self:json({
          data={
              name = "hello world"
          }
      })
  end
  return User
  ```

- 添加model

  ```lua
  local Base = require "model.base"
  
  local User = Base:extend()
  
  return User("sls_p_user",'suid')
  ```

- 控制器使用model

  ```lua
  local userModel = require('model.user')
  
  function User:index() 
      self:json({
          data={
              name = userModel:columns('rname'):get(1)
          }
      })
  end
  ```

### model封装的快捷方法说明

- 添加

  ```lua
  local data = {
      name = "test",
      pwd = 123
  }
  local insertId = userModel:create(data)
  ```

- 删除

  - 根据主键删除

    ```lua
    local affect_rows = userModel:delete(2)
    ```

  - 根据where条件删除

    ```lua
    local affect_rows = userModel:where("name","=",3):delete()
    ```

- 修改

  - 根据主键修改

    ```lua
    local affect_rows = userModel:update(data,2)
    
    local data = {
        suid = "1", -- data里面存在主键，根据主键更新
        name = "hello 我的测试",
    }
    local affect_rows = userModel:update(data)
    ```

  - 根据where条件修改

    ```lua
    local affect_rows = userModel:where("name","=",3):update(data)
    ```

- 查找

  - 查找一条记录

    ```lua
    local info = userModel:where("name","=",3):get() --根据where条件查找
    local info = userModel:get(1) --根据主键查找
    local info = userModel:columns('suid,name'):get(1) --查找指定字段,查找字段是字符串
    local info = userModel:columns({'suid','name'}):get(1) --查找指定字段,查找字段是table
    ```

  - 查找多条记录

    ```lua
    local list = userModel:where("name","=",3):all() --根据where条件查找
    local list = userModel:columns('suid,name'):all() --查找指定字段,查找字段是字符串
    local list = userModel:columns({'suid','name'}):all() --查找指定字段,查找字段是table
    ```

- 其它方法说明

  - 查找数据条数

    ```lua
    local count = userModel:where("name","=","json"):count()
    ```

  - 排序

    ```lua
    local list = userModel:where("name","=",3):orderby("id"):all()
    
    local list = userModel:where("name","=",3):orderby("name","asc"):orderby("id","desc"):all() --多个排序
    ```

  - 查找指定字段(不使用指定字段，则是查找所有字段)

    ```lua
    local list = userModel:columns('suid,name'):all() --columns里面可以是字符串，也可以是table结构
    ```

  - 根据where条件查找

    ```lua
    local list = userModel:columns('suid,rname'):where("suid","<","30"):orderby("suid"):all()
    
    local list = userModel:columns('suid,rname'):where("suid","<","30"):where("rname","like","test%"):orderby("suid"):all() -- 可以多个where
    ```

  - 自定义执行的sql

    ```lua
    -- 关联查询
    local sql = "select su.*,c.logincount from sls_p_user su join c_user c on su.suid=c.suid where su.suid=2"
    local result = userModel:query(sql)
    
    -- 动态参数查询
    local sql = "select * from sls_p_user where suid=? and username=?"
    local result = userModel:query(sql,{1,"json"})
    ```

    


��openresty���һ������web api��ܣ�����֮���õ�ʱ�����������Ŀ�ṹ

### Ŀ¼�ṹ

�ṹ������config��controller��libs��model�ĸ�Ŀ¼

- config

  �����ļ�Ŀ¼������app��redis��database��ص�����

  - appӦ�����

  ```lua
  return {
  	default_controller = 'home', -- Ĭ�Ͽ�����
  	default_action	   = 'index', -- Ĭ�Ϸ���
  }
  ```

  - ���ݿ����

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

  - redis����

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

- libsĿ¼

  libsĿ¼����Ĺ�����ģ��⣬����redis��db��request��response��

- controllerĿ¼

  ���ǿ�����Ŀ¼��������һ����װ��һ������Base.lua,ҵ��������̳�������ɣ�������ҵ���������������

  ```lua
  -- home.lua
  local Base = require("controller.base")
  
  local Home = Base:extend()
  
  function Home:index() 
      self:json({data={}})
  end
  ```

  ����Ĵ����ʵ����һ��������������·��hostname://home/index��������index����,�����url������hostname+controller�ļ����µ��ļ���+/+�ļ��еķ�����**(ע��һ��Ҫ�̳�Baseģ��)**

  controller�����ṩ�˼�����������

  - self.request��ȡ������ز�������self.request.query.xx��ȡget������self.request.body.xx��ȡpost������self.request.headers.xx��ȡheader������

  - self.response�����Ӧ�������Ҫ��self.response:json()����data������Լ�self.response:redirect()��ת,self.response.get_body()��ȡ��Ӧ�����

    Ϊ�˷��㿪������Base�����װ��response���ṩ��self:json(),self:error(code,message)������ݷ���

    ```lua
    self:json({data=self.redis:get("test")}) --���ؽ������data
    self:error(2,"��ȡ����ʧ��") --���ؽ�����ô����룬������Ϣ
    ```

    ���صĽṹ����data,code,message�ֶ�

    ```lua
    {"data":{"data":["BBBBB","B","AAAAA","A","BBBBB","B","AAAAA","A"]},"message":"","code":"��ȡ�ɹ�"}
    ```

  - self.redis����ʹ��redis������self.redis:set,self.redis:get,self.redis:hset,self.redis:hget�ȵȣ��������ʹ�õĺ������Բο�**libs/redis.lua**�ļ���15��72��

  - self.controller��ȡ��ǰ����������

  - self.action��ȡ��ǰaction��������

- modelĿ¼

  ģ����أ�Ϊ�˱��ڲ�����Ҳ��װ��һ��Base���࣬ҵ��modelֻ��Ҫ�̳м���

  ```lua
  -- good.lua
  local Base = require "model.base"
  
  local Good = Base:extend() --�̳�Base
  
  return Good("test",'lgid') --��һ������������,�ڶ��������Ǳ��Ӧ������(Ĭ��Ϊid)
  ```

  Base.lua��װ�Ļ����ṩ�˵�����ɾ�Ĳ�ķ���

  - create(data)��Ӽ�¼
  - delete(id)ɾ����¼
  - update(data,id)�޸ļ�¼
  - get()��all()���˼�¼
  - where()������������
  - columns()���ò�����Щ�еķ���
  - orderby()��������ķ���
  - count()���������������ķ���

  ͬʱBase.luaҲ�ṩ��һ�����������Զ���ִ��sql�ķ��������㸴�Ӳ�ѯ

  - query()

### ���ٿ�ʼ

- nginx.conf����������´���

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
            log_not_found off;#�ر���־
            access_log off;#����¼��access.log
          }
  
          location / {
              default_type text/html;
              content_by_lua_file "E:/openresty/demo/src/main.lua";
          }
      }
  }
  ```

- ��ӿ�����

  ��controllerĿ¼���user.lua

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

- ���model

  ```lua
  local Base = require "model.base"
  
  local User = Base:extend()
  
  return User("sls_p_user",'suid')
  ```

- ������ʹ��model

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

### model��װ�Ŀ�ݷ���˵��

- ���

  ```lua
  local data = {
      name = "test",
      pwd = 123
  }
  local insertId = userModel:create(data)
  ```

- ɾ��

  - ��������ɾ��

    ```lua
    local affect_rows = userModel:delete(2)
    ```

  - ����where����ɾ��

    ```lua
    local affect_rows = userModel:where("name","=",3):delete()
    ```

- �޸�

  - ���������޸�

    ```lua
    local affect_rows = userModel:update(data,2)
    
    local data = {
        suid = "1", -- data�������������������������
        name = "hello �ҵĲ���",
    }
    local affect_rows = userModel:update(data)
    ```

  - ����where�����޸�

    ```lua
    local affect_rows = userModel:where("name","=",3):update(data)
    ```

- ����

  - ����һ����¼

    ```lua
    local info = userModel:where("name","=",3):get() --����where��������
    local info = userModel:get(1) --������������
    local info = userModel:columns('suid,name'):get(1) --����ָ���ֶ�,�����ֶ����ַ���
    local info = userModel:columns({'suid','name'}):get(1) --����ָ���ֶ�,�����ֶ���table
    ```

  - ���Ҷ�����¼

    ```lua
    local list = userModel:where("name","=",3):all() --����where��������
    local list = userModel:columns('suid,name'):all() --����ָ���ֶ�,�����ֶ����ַ���
    local list = userModel:columns({'suid','name'}):all() --����ָ���ֶ�,�����ֶ���table
    ```

- ��������˵��

  - ������������

    ```lua
    local count = userModel:where("name","=","json"):count()
    ```

  - ����

    ```lua
    local list = userModel:where("name","=",3):orderby("id"):all()
    
    local list = userModel:where("name","=",3):orderby("name","asc"):orderby("id","desc"):all() --�������
    ```

  - ����ָ���ֶ�(��ʹ��ָ���ֶΣ����ǲ��������ֶ�)

    ```lua
    local list = userModel:columns('suid,name'):all() --columns����������ַ�����Ҳ������table�ṹ
    ```

  - ����where��������

    ```lua
    local list = userModel:columns('suid,rname'):where("suid","<","30"):orderby("suid"):all()
    
    local list = userModel:columns('suid,rname'):where("suid","<","30"):where("rname","like","test%"):orderby("suid"):all() -- ���Զ��where
    ```

  - �Զ���ִ�е�sql

    ```lua
    -- ������ѯ
    local sql = "select su.*,c.logincount from sls_p_user su join c_user c on su.suid=c.suid where su.suid=2"
    local result = userModel:query(sql)
    
    -- ��̬������ѯ
    local sql = "select * from sls_p_user where suid=? and username=?"
    local result = userModel:query(sql,{1,"json"})
    ```

    


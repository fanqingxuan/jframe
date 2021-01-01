local mysql_config = {
    timeout = 5000,
    connect_config = {
        host = "127.0.0.1",
        port = 3306,
        database = "demo",
        user = "root",
        password = "root",
        max_packet_size = 1024 * 1024
    },
    pool_config = {
        max_idle_timeout = 20000, -- 20s
        pool_size = 50 -- connection pool size
    }
}

return mysql_config
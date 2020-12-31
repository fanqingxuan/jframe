local mysql_config = {
    timeout = 5000,
    connect_config = {
        host = "192.168.40.24",
        port = 3306,
        database = "lty_trj0508",
        user = "root",
        password = "a12345",
        max_packet_size = 1024 * 1024
    },
    pool_config = {
        max_idle_timeout = 20000, -- 20s
        pool_size = 50 -- connection pool size
    }
}

return mysql_config
##### druid

```yml
# 数据库链接池配置 druid


# JDBC 基本配置
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/test?useSSL=true&useUnocode=true&characterEncoding=UTF8&serverTimezone=GMT
    username: test
    password: mysql
    druid:
      # Druid 连接池配置
      initial-size: 8
      max-active: 32
      min-idle: 8
      max-wait: 60000
      validation-query-timeout: 60000
      time-between-eviction-runs-millis: 60000
      min-evictable-idle-time-millis: 100000
      max-pool-prepared-statement-per-connection-size: 20
      pool-prepared-statements: true
      validation-query: 'SELECT 1 FROM DUAL'
      test-on-borrow: false
      test-on-return: false
      test-while-idle: false
      filters: stat,wall,log4j
      # 配置监控
      web-stat-filter:
        enabled: true
        url-pattern: '/*'
        exclusions: '*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*'
      # StatViewServlet 配置，说明请参考 Druid Wiki，配置 StatViewServlet 配置
      stat-view-servlet:
        enabled: true
        url-pattern: '/druid/*'
        reset-enable: false
        login-username: admin
        login-password: admin
        allow: 127.0.0.1
      # 配置 StatFilter
      filter:
        stat:
          db-type: mysql
          log-slow-sql: true
          slow-sql-millis: 5000
        # 配置 WallFilter
        wall:
          enabled: true
          db-type: mysql
          config:
            delete-allow: false
            drop-table-allow: false
```



##### hikari

```yml
# 数据库链接池配置 hikaricp

params:
  dbhost: 192.168.50.10
  driver: com.mysql.cj.jdbc.Driver
  url: jdbc:mysql://${params.dbhost}:3306/test?useSSL=true&useUnocode=true&characterEncoding=UTF8&serverTimezone=GMT
  username: normal
  password: mysql

# JDBC 基本配置
spring:
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    driver-class-name: ${params.driver}
    url: ${params.url}
    username: ${params.username}
    password: ${params.password}
    hikari:
      minimum-idle: 10
      maximum-pool-size: 32
      auto-commit: true
      idle-timeout: 600000
      max-lifetime: 1800000
      connection-timeout: 30000
      connection-test-query: 'SELECT 1'
```




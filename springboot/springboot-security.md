## 密码技术关键

1. 单向哈希 - HASH (如： SHA-256) 保存密码

2. 加盐 (salted) 后在哈希加密保存密码。


在现代，意识到加密哈希（例如SHA-256）不再安全，原因是使用现代硬件，可以每秒执行数十亿次哈希计算。这意味着可以轻松地分别破解每个密码。

**关键技术：**

* Rainbow table
* bcrypt
* PBKDF2
* scrypt
* argon2

**常见漏洞 (exploits)**

* Cross Site Request Forgery (CSRF) - 跨站请求伪造
*  XSS attack

## spring security + oauth2

### 引入依赖

```gradle
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'
    implementation 'org.springframework.cloud:spring-cloud-starter-oauth2'
    implementation 'io.jsonwebtoken:jjwt:0.9.1'
```

### security 用户身份认证和授权

```java
@Configuration
@EnableWebSecurity
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {

        http.formLogin().permitAll();
        /*http.formLogin()
                .loginPage("/login.html")
                .loginProcessingUrl("/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .permitAll();*/

        http.authorizeRequests()
                .antMatchers("/oauth/**", "/login/**", "/logout/**").permitAll()
                .anyRequest().authenticated();

        http.csrf().disable();
    }
}
```

配置用户认证服务逻辑

```java
@Service
public class DefaultUserDetailsService implements UserDetailsService {

    private final static Logger log = LoggerFactory.getLogger(DefaultUserDetailsService.class);

    private PasswordEncoder passwordEncoder;

    public DefaultUserDetailsService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        System.out.println("自定义登录逻辑，用户 [" + username + "]");
        if (null == username || "".equals(username)) {
            log.error("userName is null");
            throw new UsernameNotFoundException("username is empty");
        }

        if ("admin".equals(username)) {
            return new DefaultUserDetails("admin", passwordEncoder.encode("123456"),
                    AuthorityUtils.commaSeparatedStringToAuthorityList("admin,normal,ROLE_admin,access"));
        } else if ("normal".equals(username)) {
            return new DefaultUserDetails("normal", passwordEncoder.encode("123456"),
                    AuthorityUtils.commaSeparatedStringToAuthorityList("normal,ROLE_normal,ROLE_access"));
        } else if ("other".equals(username)) {
            return new DefaultUserDetails("other", passwordEncoder.encode("123456"),
                    AuthorityUtils.commaSeparatedStringToAuthorityList("other,ROLE_other,ROLE_access"));
        } else if ("anonymous".equals(username)) {
            return new DefaultUserDetails("anonymous", passwordEncoder.encode("123456"),
                    AuthorityUtils.commaSeparatedStringToAuthorityList("anonymous,access"));
        } else if ("access".equals(username)) {
            return new DefaultUserDetails("access", passwordEncoder.encode("123456"),
                    AuthorityUtils.commaSeparatedStringToAuthorityList("/access.html"));
        } else {
            log.error("cannot find username [{}] user info", username);
            throw new UsernameNotFoundException("user not exists");
        }

    }

}
```

### oauth2 server 配置

继承 `AuthorizationServerConfigurerAdapter` *OAuth2* 服务端适配类，添加 `@EnableAuthorizationServer` 注解启用 *OAuth2* 服务端配置。

配置服务端认证源，和 *OAuth2* 认证的 *client_id*， *client_secret* 和支持的认证类型

```java
@Configuration
@EnableAuthorizationServer
public class SecurityOAuth2ServerConfiguration extends AuthorizationServerConfigurerAdapter {

        @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        endpoints.userDetailsService(defaultUserDetailsService)
                .authenticationManager(authenticationManagerBean)
                .accessTokenConverter(myJwtAccessTokenConverter)
                .tokenStore(new InMemoryTokenStore());
    }

    /**
     * http://10.0.41.80:30050/oauth/authorize?client_id=oauth_client&response_type=code&scop=all@redirect_uri=http://www.baidu.com
     */
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()
                .withClient("oauth_client")
                .secret(passwordEncoder.encode("123456"))
                .redirectUris("http://www.baidu.com")
                //.redirectUris("http://10.0.41.80:30060/login")
                .scopes("all")
                .autoApprove(false)
                .accessTokenValiditySeconds(36000)
                .refreshTokenValiditySeconds(36000)
                .authorizedGrantTypes("authorization_code", "password", "refresh_token");
    }
    
}
```

### oauth2 resources 配置

继承 `ResourceServerConfigurerAdapter`  *OAuth2* 资源适配类，配置那些资源需要 *OAuth2* 认证。

```java
@Configuration
@EnableResourceServer
public class SecurityOAuth2ResourceConfiguration extends ResourceServerConfigurerAdapter {
    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests().anyRequest().authenticated();
        http.requestMatchers().antMatchers("/user/**");
    }
}
```

### OAuth2 SSO 配置

在启动类上添加 `@EnableOAuth2Sso` 注解

```properties
server.port=30060
spring.application.name=securityOAuth2SSO
server.servlet.session.cookie.name=OAUTH2-CLIENT-SESSION01

oauth2-server-uri=http://10.0.41.80:30050

security.oauth2.client.client-id=oauth_client
security.oauth2.client.client-secret=123456
security.oauth2.client.user-authorization-uri=${oauth2-server-uri}/oauth/authorize
security.oauth2.client.access-token-uri=${oauth2-server-uri}/oauth/token
#security.oauth2.resource.jwt.key-uri=${oauth2-server-uri}/oauth/token_key
security.oauth2.resource.user-info-uri=${oauth2-server-uri}/user/getCurrentUser
```


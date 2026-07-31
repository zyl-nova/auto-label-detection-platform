package com.idtserver.mrserver.config;


import com.idtserver.mrserver.jwt.endpoint.JWTAuthenticationEntryPoint;
import com.idtserver.mrserver.jwt.endpoint.JWTAuthorizationFilter;
import com.idtserver.mrserver.jwt.handler.JWTAuthenticationFailureHandler;
import com.idtserver.mrserver.jwt.handler.JWTAuthenticationSuccessHandler;
import com.idtserver.mrserver.jwt.mobile.MobileAuthenticationProcessingFilter;
import com.idtserver.mrserver.jwt.mobile.MobileAuthenticationProvider;
import com.idtserver.mrserver.jwt.password.UsernameAuthenticationFilter;
import com.idtserver.mrserver.jwt.password.UsernameAuthenticationProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    @Qualifier("userDetailsServiceImpl")
    private UserDetailsService userDetailsService;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
//        auth.userDetailsService(userDetailsService)
//            .passwordEncoder(passwordEncoder());
        auth.authenticationProvider(new MobileAuthenticationProvider());
        UsernameAuthenticationProvider usernameAuthenticationProvider = new UsernameAuthenticationProvider();
        usernameAuthenticationProvider.setPasswordEncoder(passwordEncoder());
        usernameAuthenticationProvider.setUserDetailsService(userDetailsService);
        auth.authenticationProvider(usernameAuthenticationProvider);

    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        AuthenticationSuccessHandler successHandler = new JWTAuthenticationSuccessHandler(redisTemplate);
        AuthenticationFailureHandler failureHandler = new JWTAuthenticationFailureHandler();
        MobileAuthenticationProcessingFilter mobileAuthenticationProcessingFilter = new MobileAuthenticationProcessingFilter(authenticationManager());
        mobileAuthenticationProcessingFilter.setAuthenticationSuccessHandler(successHandler);
        mobileAuthenticationProcessingFilter.setAuthenticationFailureHandler(failureHandler);
        UsernameAuthenticationFilter jwtAuthenticationFilter = new UsernameAuthenticationFilter(authenticationManager());
        jwtAuthenticationFilter.setAuthenticationSuccessHandler(successHandler);
        jwtAuthenticationFilter.setAuthenticationFailureHandler(failureHandler);
        http.csrf().disable()
                .authorizeRequests()
                .anyRequest().authenticated()
                .and()
                .addFilterBefore(mobileAuthenticationProcessingFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(jwtAuthenticationFilter,  UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(new JWTAuthorizationFilter(authenticationManager()), UsernamePasswordAuthenticationFilter.class)
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .exceptionHandling().authenticationEntryPoint(new JWTAuthenticationEntryPoint());
    }




}

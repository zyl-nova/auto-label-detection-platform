package com.idtserver.mrserver.service.impl;

import com.idtserver.mrserver.entity.AuthUser;
import com.idtserver.mrserver.service.UpmsService;
import com.idtserver.mrserver.util.StatusCode;
import com.idtserver.mrserver.vo.MenuVo;
import com.idtserver.mrserver.vo.Result;
import com.idtserver.mrserver.vo.RoleVo;
import com.idtserver.mrserver.vo.UserVo;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;


@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    @Autowired
    private UpmsService upmsService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Result<UserVo> userResult = upmsService.findByUsername(username);
        if (userResult.getCode() != StatusCode.SUCCESS_CODE) {
            throw new UsernameNotFoundException("用户:" + username + ",不存在!");
        }
        Set<SimpleGrantedAuthority> grantedAuthorities = new HashSet<>();
        UserVo userVo = new UserVo();
        BeanUtils.copyProperties(userResult.getData(),userVo);
        Result<List<RoleVo>> roleResult = upmsService.getRoleByUserId(userVo.getId());
        if (roleResult.getCode() == StatusCode.SUCCESS_CODE){
            List<RoleVo> roleVoList = roleResult.getData();
            for (RoleVo role:roleVoList){
                //角色必须是ROLE_开头，可以在数据库中设置
                SimpleGrantedAuthority grantedAuthority = new SimpleGrantedAuthority("ROLE_"+role.getValue());
                grantedAuthorities.add(grantedAuthority);
                //获取权限
                Result<List<MenuVo>> perResult  = upmsService.getRolePermission(role.getId());
                if (perResult.getCode() == StatusCode.SUCCESS_CODE){
                    List<MenuVo> permissionList = perResult.getData();
                    for (MenuVo menu:permissionList
                            ) {
                        if ( !StringUtils.isEmpty(menu.getUrl()) ){
                            SimpleGrantedAuthority authority = new SimpleGrantedAuthority(menu.getUrl());
                            grantedAuthorities.add(authority);
                        }
                    }
                }
            }
        }
        AuthUser user = new AuthUser(userVo.getUsername(), userVo.getPassword(), grantedAuthorities);
        user.setId(userVo.getId());
        return user;
    }
}

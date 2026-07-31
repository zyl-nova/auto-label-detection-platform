package com.idtserver.mrserver.service.impl;


import com.idtserver.mrserver.entity.SysUser;
import com.idtserver.mrserver.mapper.SysUserMapper;
import com.idtserver.mrserver.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tk.mybatis.mapper.entity.Example;
import tk.mybatis.mapper.util.Sqls;

import javax.annotation.Resource;

@Service
public class UserServiceImpl implements UserService {

    @Resource
    private SysUserMapper userMapper;

    @Override
    public SysUser findByUsername(String username) {
        Example example = Example.builder(SysUser.class)
                .where(Sqls.custom().andEqualTo("username",username))
                .build();
        return userMapper.selectOneByExample(example);
    }
}

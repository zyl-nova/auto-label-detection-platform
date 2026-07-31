package com.idtserver.mrserver.service.impl;

import com.idtserver.mrserver.entity.SysRole;
import com.idtserver.mrserver.mapper.SysRoleMapper;
import com.idtserver.mrserver.service.RoleService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;


@Service
public class RoleServiceImpl implements RoleService {

    @Resource
    private SysRoleMapper roleMapper;

    @Override
    public List<SysRole> getRoleByUserId(Integer userId) {
        return roleMapper.getRoleByUserId(userId);
    }
}

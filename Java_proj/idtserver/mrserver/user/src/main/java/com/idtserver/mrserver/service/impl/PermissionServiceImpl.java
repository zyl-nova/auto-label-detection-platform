package com.idtserver.mrserver.service.impl;


import com.idtserver.mrserver.entity.SysMenu;
import com.idtserver.mrserver.mapper.SysMenuMapper;
import com.idtserver.mrserver.service.PermissionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;


@Service
public class PermissionServiceImpl implements PermissionService {
    @Resource
    private SysMenuMapper menuMapper;
    @Override
    public List<SysMenu> getPermissionsByRoleId(Integer roleId) {
        return menuMapper.getPermissionsByRoleId(roleId);
    }
}

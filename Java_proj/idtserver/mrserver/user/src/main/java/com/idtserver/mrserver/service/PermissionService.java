package com.idtserver.mrserver.service;



import com.idtserver.mrserver.entity.SysMenu;

import java.util.List;

public interface PermissionService {
    List<SysMenu> getPermissionsByRoleId(Integer roleId);
}

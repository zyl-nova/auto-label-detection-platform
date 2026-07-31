package com.idtserver.mrserver.service;


import com.idtserver.mrserver.entity.SysRole;

import java.util.List;


public interface RoleService {
    List<SysRole> getRoleByUserId(Integer userId);
}

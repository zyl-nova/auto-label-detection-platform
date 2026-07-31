package com.idtserver.mrserver.service;

import com.idtserver.mrserver.entity.SysUser;

public interface UserService {
    SysUser findByUsername(String username);
}

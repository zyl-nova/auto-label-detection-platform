package com.idtserver.mrserver.service.impl;

import com.idtserver.mrserver.service.UpmsService;
import com.idtserver.mrserver.vo.MenuVo;
import com.idtserver.mrserver.vo.Result;
import com.idtserver.mrserver.vo.RoleVo;
import com.idtserver.mrserver.vo.UserVo;
import feign.hystrix.FallbackFactory;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;


@Slf4j
@Component
public class UpmsServiceFallbackFactory implements FallbackFactory<UpmsService> {
    @Override
    public UpmsService create(Throwable throwable) {
        log.error("调用UPMS失败", throwable);
        return new UpmsService() {
            @Override
            public Result<UserVo> findByUsername(String username) {
                return Result.failure(201,"调用失败");
            }

            @Override
            public Result<List<RoleVo>> getRoleByUserId(Integer userId) {
                return Result.failure(201,"调用失败");
            }

            @Override
            public Result<List<MenuVo>> getRolePermission(Integer roleId) {
                return Result.failure(201,"调用失败");
            }
        };
    }
}

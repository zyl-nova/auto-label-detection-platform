package com.idtserver.mrserver.controller;

import com.idtserver.mrserver.dto.BusinessState;
import com.idtserver.mrserver.dto.BusinessStatePayload;
import com.idtserver.mrserver.mapper.BusinessStateMapper;
import com.idtserver.mrserver.result.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

@RestController
@RequestMapping("BusinessState")
public class BusinessStateController {
    private static final String DEFAULT_STATE_KEY = "business";

    @Resource
    private BusinessStateMapper businessStateMapper;

    @GetMapping("load")
    public Result<BusinessState> load(@RequestParam(value = "stateKey", required = false) String stateKey) {
        String key = stateKey == null || stateKey.trim().isEmpty() ? DEFAULT_STATE_KEY : stateKey;
        return Result.success(businessStateMapper.getBusinessState(key));
    }

    @PostMapping("save")
    public Result<?> save(@RequestBody BusinessStatePayload payload) {
        String key = payload.getStateKey() == null || payload.getStateKey().trim().isEmpty()
                ? DEFAULT_STATE_KEY
                : payload.getStateKey();
        if (payload.getStateData() == null || payload.getStateData().trim().isEmpty()) {
            return Result.failure("stateData is required");
        }
        return Result.success(businessStateMapper.upsertBusinessState(key, payload.getStateData()));
    }
}

package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;

@Data
public class BusinessState {
    private String stateKey;
    private String stateData;
    private Date updateTime;
}

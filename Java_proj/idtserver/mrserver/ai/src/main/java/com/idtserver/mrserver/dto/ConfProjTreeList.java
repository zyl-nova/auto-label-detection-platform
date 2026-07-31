package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.Date;

@Data
public class ConfProjTreeList {
    String id;
    String code;
    String pCode;
    String pId;
    String name;
    Integer sort;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
}

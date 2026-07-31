package com.idtserver.mrserver.domain;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class ModelCenterTreeNodeParent {
    String id;
    String code;
    String pCode;
    String pId;
    String name;
    Integer sort;
    Date createTime;
    Date updateTime;
    Integer logicalDelete;
    List<ModelCenterTreeNodeChildren> children;
}

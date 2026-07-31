package com.idtserver.mrserver.service;

import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.domain.ModelCenterTreeNodeParent;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;

import java.util.List;

public interface TaskCenterService {

    //根据查询条件， 分页查看模型列表
    PageInfo<InfoTaskCenterTrainInfo> getDetailModelList(String mainInfo,
                                                              Boolean isDesc,
                                                              Integer modelStatus,
                                                              int pageNum,
                                                              int pageSize);

    //新增模型，并开启训练
    Long addNewTask(InfoTaskCenterTrainInfo model, String modelPath);

    //更新模型
    int updateTask(InfoTaskCenterTrainInfo model);

    //删除模型
    int deleteTask(Long modelId);
}

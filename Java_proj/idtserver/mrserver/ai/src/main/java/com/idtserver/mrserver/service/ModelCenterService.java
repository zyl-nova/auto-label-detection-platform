package com.idtserver.mrserver.service;

import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.domain.ModelCenterTreeNodeParent;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import org.apache.ibatis.annotations.Param;

import javax.sound.sampled.Line;
import java.util.List;

public interface ModelCenterService {
    //查看项目树状列表
    List<ModelCenterTreeNodeParent> getModelCenterTree();


    //根据查询条件， 分页查看模型列表
    PageInfo<InfoModelCenterModelBaseInfo> getDetailModelList(
                                                                String projId,
                                                                String mainInfo,
                                                              Boolean isDesc,
                                                              Integer modelStatus,
                                                              int pageNum,
                                                              int pageSize);

    //新增模型，并开启训练
    Long addNewModel(InfoModelCenterModelBaseInfo model);

    //更新模型
    int updateModel(InfoModelCenterModelBaseInfo model);

    //删除模型
    int deleteModel(Long modelId);
}

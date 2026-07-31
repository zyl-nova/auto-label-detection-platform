package com.idtserver.mrserver.service.impl;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.domain.ModelCenterTreeNodeChildren;
import com.idtserver.mrserver.domain.ModelCenterTreeNodeParent;
import com.idtserver.mrserver.dto.ConfProjTreeList;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.mapper.ModelCenterMapper;
import com.idtserver.mrserver.service.ModelCenterService;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Collections;
import java.util.Date;
import java.util.List;

@Service
public class ModelCenterServiceImpl implements ModelCenterService {

    @Resource
    private ModelCenterMapper modelCenterMapper;


    @Override
    public List<ModelCenterTreeNodeParent> getModelCenterTree() {
        //父级节点
        List<ModelCenterTreeNodeParent> parents = new java.util.ArrayList<>(Collections.emptyList());
        List<ConfProjTreeList> rawDataList = modelCenterMapper.getConfModelCenterTreeList();
        //先把父节点取出
        rawDataList.forEach(e ->{
            ModelCenterTreeNodeParent parent = new ModelCenterTreeNodeParent();
            if(null == e.getPId()){
                BeanUtils.copyProperties(e, parent);
                parents.add(parent);
            }
        });
        //再对父节点填写对应的子节点
        parents.forEach(p -> {
            List<ModelCenterTreeNodeChildren> childrenNodeList = new java.util.ArrayList<>(Collections.emptyList());
            rawDataList.stream().filter(item -> item.getPId() != null).forEach(e -> {

                ModelCenterTreeNodeChildren child = new ModelCenterTreeNodeChildren();
                if(e.getPId().equals(p.getId())){
                    BeanUtils.copyProperties(e, child);
                    childrenNodeList.add(child);
                }
            });
            p.setChildren(childrenNodeList);
        });
        return parents;
    }

    @Override
    public PageInfo<InfoModelCenterModelBaseInfo> getDetailModelList(   String projId,
                                                                        String mainInfo,
                                                                       Boolean isDesc,
                                                                       Integer modelStatus,
                                                                       int pageNum,
                                                                       int pageSize)
    {

        PageHelper.startPage(pageNum, pageSize);
        List<InfoModelCenterModelBaseInfo> modelList =
                modelCenterMapper.getInfoModelCenterModelBaseInfo(projId, mainInfo, isDesc, modelStatus);

        return new PageInfo<>(modelList);
    }

    @Override
    public Long addNewModel(InfoModelCenterModelBaseInfo model) {
        model.setCreateTime(new Date());
        model.setUpdateTime(new Date());
        model.setLogicalDelete(0);
        model.setStatus(2);
        Long confModelCenterModelBaseInfo = modelCenterMapper.createConfModelCenterModelBaseInfo(model);
        //todo:调用训练接口
        return confModelCenterModelBaseInfo;
    }

    @Override
    public int updateModel(InfoModelCenterModelBaseInfo model) {
        return modelCenterMapper.updateConfModelCenterModelBaseInfo(model);
    }

    @Override
    public int deleteModel(Long modelId) {
        return modelCenterMapper.deleteConfModelCenterModelBaseInfo(modelId);
    }
}

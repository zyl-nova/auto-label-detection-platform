package com.idtserver.mrserver.service.impl;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;
import com.idtserver.mrserver.mapper.ModelCenterMapper;
import com.idtserver.mrserver.mapper.TaskCenterMapper;
import com.idtserver.mrserver.service.TaskCenterService;
import com.idtserver.mrserver.utils.StoreMutipartFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.IOException;
import java.util.Date;
import java.util.List;

@Service
public class TaskCenterServiceImpl implements TaskCenterService {

    @Resource
    TaskCenterMapper taskCenterMapper;

    @Resource
    ModelCenterMapper  modelCenterMapper;

    @Override
    public PageInfo<InfoTaskCenterTrainInfo> getDetailModelList(String mainInfo,
                                                                     Boolean isDesc,
                                                                     Integer modelStatus,
                                                                     int pageNum,
                                                                     int pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<InfoTaskCenterTrainInfo> tasks = taskCenterMapper.getTasks(mainInfo, isDesc, modelStatus);


        return new PageInfo<>(tasks);
    }

    @Override
    public Long addNewTask(InfoTaskCenterTrainInfo model, String modelPathTmp) {
        String modelPath = "";
        try {
            StoreMutipartFile storeMutipartFile = new StoreMutipartFile();
            modelPath = storeMutipartFile.createNewFile(modelPathTmp);
        }catch (Exception e){
            e.printStackTrace();
        }



        InfoModelCenterModelBaseInfo info = new InfoModelCenterModelBaseInfo();
        info.setStatus(0);
        info.setCreateTime(new Date());
        info.setUpdateTime(new Date());
        info.setLogicalDelete(0);
        info.setModelDirUrl(modelPath);


        Long modelId = modelCenterMapper.createConfModelCenterModelBaseInfo(info);
        model.setModelId(info.getId());
        model.setUpdateTime(new Date());
        model.setCreateTime(new Date());
        model.setLogicalDelete(0);
        Long id = taskCenterMapper.createTask(model);
        //todo:调用训练接口
        return id;
    }

    @Override
    public int updateTask(InfoTaskCenterTrainInfo model) {
        return taskCenterMapper.updateTask(model);
    }

    @Override
    public int deleteTask(Long modelId) {
        return taskCenterMapper.deleteTask(modelId);
    }
}

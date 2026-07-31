package com.idtserver.mrserver.mapper;

import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface TaskCenterMapper {
    //任务中心，增加新任务
    Long createTask(InfoTaskCenterTrainInfo infoModelCenterModelBaseInfo);

    //任务中心，查询任务
    List<InfoTaskCenterTrainInfo> getTasks(@Param("mainInfo") String mainInfo,
                                                @Param("isDesc") Boolean isDesc,
                                                @Param("modelStatus") Integer modelStatus);
    //任务中心，更新单个任务信息
    int updateTask(InfoTaskCenterTrainInfo infoModelCenterModelBaseInfo);

    //任务中心，删除任务
    int deleteTask(@Param("id") Long id);
}

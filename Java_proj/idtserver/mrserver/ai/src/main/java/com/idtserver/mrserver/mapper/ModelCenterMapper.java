package com.idtserver.mrserver.mapper;

import com.idtserver.mrserver.dto.ConfProjTreeList;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;


/**
 * 模型中心的sql mapper文件
 */
@Mapper
public interface ModelCenterMapper {
    //模型中心，项目列表查询
    List<ConfProjTreeList> getConfModelCenterTreeList();

    //模型中心，增加（同时训练）模型
    Long createConfModelCenterModelBaseInfo(InfoModelCenterModelBaseInfo modelBaseInfo);

    //模型中心，查询所有模型情况
    List<InfoModelCenterModelBaseInfo> getInfoModelCenterModelBaseInfo(
                                                                        @Param("projId") String projId,
                                                                        @Param("mainInfo") String mainInfo,
                                                                        @Param("isDesc") Boolean isDesc,
                                                                        @Param("modelStatus") Integer modelStatus);

    //模型中心，更新单个模型配置
    int updateConfModelCenterModelBaseInfo(InfoModelCenterModelBaseInfo modelBaseInfo);

    //模型中心，删除模型
    int deleteConfModelCenterModelBaseInfo(@Param("id") Long id);

}

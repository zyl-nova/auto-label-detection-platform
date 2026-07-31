package com.idtserver.mrserver.mapper;

import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.MapLabelTaskPicsToUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;


/**
 * 模型中心的sql mapper文件
 */
@Mapper
public interface ImageLabelMapper {
    //查询出来所有已经准备妥当文档记录
    List<FileManager> getAllFileManagerList(@Param("projId") String projId);



}

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
public interface FileManagerMapper {
    //文件管理，列表记录查询
    List<FileManager> getFileManagerRecordList(@Param("projId") String projId,
                                               @Param("mainInfo") String mainInfo,
                                               @Param("isDesc") Boolean isDesc,
                                               @Param("fileType") Integer fileType);

    FileManager getFileManagerRecordById(@Param("id") Long id);

    //文件管理，创建记录
    Long createFileManagerRecord(FileManager fileManager);

    //文件管理，更新文件管理记录
    int updateFileManagerRecord(FileManager fileManager);

    //文件管理，文件管理记录
    int deleteFileManagerRecord(@Param("id") Long id);

    //把每张图片插入到map_label_task_pics_to_user表中
    int createPicsForLabeling(List<MapLabelTaskPicsToUser> picsToInsert);

}

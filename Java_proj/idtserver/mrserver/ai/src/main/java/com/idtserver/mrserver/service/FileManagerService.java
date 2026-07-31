package com.idtserver.mrserver.service;

import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;

public interface FileManagerService {

    //根据查询条件， 分页查看文件管理列表
    PageInfo<FileManager> getFileManagerList(String projId,
                                             String mainInfo,
                                             Boolean isDesc,
                                             int pageNum,
                                             int pageSize,
                                             int fileType);

    //新增文件上传记录
    Long addNewFileManagerRecord(FileManager fileManager,String filePath);

    //更新模型
    int updateFileManagerRecord(FileManager fileManager);

    //删除模型
    int deleteFileManagerRecord(Long modelId);
}

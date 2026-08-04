package com.idtserver.mrserver.mapper;

import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.MapLabelTaskPicsToUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ImageLabelMapper {
    List<FileManager> getAllFileManagerList(@Param("projId") String projId);

    MapLabelTaskPicsToUser getSavedAnnotation(@Param("taskId") Long taskId,
                                              @Param("fileId") Long fileId);

    int createAnnotation(MapLabelTaskPicsToUser annotation);

    int updateAnnotation(MapLabelTaskPicsToUser annotation);
}

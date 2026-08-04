package com.idtserver.mrserver.mapper;

import com.idtserver.mrserver.dto.BusinessState;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface BusinessStateMapper {
    BusinessState getBusinessState(@Param("stateKey") String stateKey);

    int upsertBusinessState(@Param("stateKey") String stateKey,
                            @Param("stateData") String stateData);
}

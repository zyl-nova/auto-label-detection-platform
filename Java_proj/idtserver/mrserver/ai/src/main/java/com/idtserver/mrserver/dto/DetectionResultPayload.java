package com.idtserver.mrserver.dto;

import lombok.Data;

import java.util.List;

@Data
public class DetectionResultPayload {
    private List<DetectionBox> results;
}

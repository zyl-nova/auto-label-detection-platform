package com.idtserver.mrserver.dto;

import lombok.Data;

@Data
public class DetectionBox {
    private Integer id;
    private String label;
    private Double confidence;
    private Double x;
    private Double y;
    private Double width;
    private Double height;
}

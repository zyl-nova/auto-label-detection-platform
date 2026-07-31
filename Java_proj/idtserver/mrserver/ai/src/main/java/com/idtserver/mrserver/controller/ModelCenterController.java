package com.idtserver.mrserver.controller;

import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.domain.ModelCenterTreeNodeParent;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.result.Result;
import com.idtserver.mrserver.service.ModelCenterService;
import com.idtserver.mrserver.utils.FileValidator;
import com.idtserver.mrserver.utils.StoreMutipartFile;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Nullable;
import javax.annotation.Resource;
import java.math.BigInteger;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;

@CrossOrigin
@RestController
@RequestMapping("ModelCenter")
public class ModelCenterController {
    @Resource
    private ModelCenterService modelCenterService;

    @Value("${resources-path}")
    private  String prefix;

    @Value("${models-path}")
    private  String modelsPath;

    /**
     * 该接口接收到的是已经训练好的模型,
     * 只取第一个zip文件
     */
    @PostMapping("add")
    public Result<String> add(
                              @Nullable @RequestParam("code") String code,
                              @Nullable @RequestParam("eName")  String eName,
                              @Nullable @RequestParam("cName")  String cName,
                              @Nullable @RequestParam("projId") String projId,
                              @Nullable @RequestParam("sort")  Integer sort,
                              @Nullable @RequestParam("modelDirUrl")  String modelDirUrl,
                              @Nullable @RequestParam("status")  Integer status,
                              @Nullable @RequestParam("des")  String des,
                            @RequestParam("files") MultipartFile[] files){
        InfoModelCenterModelBaseInfo infoModelCenterModelBaseInfo = new InfoModelCenterModelBaseInfo();
        infoModelCenterModelBaseInfo.setCode(code);
        infoModelCenterModelBaseInfo.setEName(eName);
        infoModelCenterModelBaseInfo.setCName(cName);
        infoModelCenterModelBaseInfo.setProjId(projId);
        infoModelCenterModelBaseInfo.setSort(sort);
        infoModelCenterModelBaseInfo.setModelDirUrl(modelDirUrl);
        infoModelCenterModelBaseInfo.setStatus(status);
        infoModelCenterModelBaseInfo.setDes(des);

        //判断传入的字段或者文件是否为空
        if(files.length == 0){
            return Result.failure("文件为空");
        }
        //模型导入存储文件夹
        String storePath = prefix + "/" + modelsPath;

        //zip文件解压后的完整路径，要添加到数据库中
        String modelStorePath = "";
        FileValidator fileValidator = new FileValidator();
        StoreMutipartFile storeMutipartFile = new StoreMutipartFile();
        if(!files[0].isEmpty()){    //判断是否为zip文件
            boolean isZip = fileValidator.isZipFile(files[0]);
            if(isZip){      //如果是zip文件则上传存储，并解压
                Path path = Paths.get(storePath);
                modelStorePath = storeMutipartFile.uploadUnzip(path.toAbsolutePath().toString(), files[0]);
            }
        }

        //设置模型路径,存储到数据库
        infoModelCenterModelBaseInfo.setModelDirUrl(modelStorePath);

        Long result = modelCenterService.addNewModel(infoModelCenterModelBaseInfo);
        return Result.success(Long.toString(result));
    }


    @PostMapping("listTree")
    public Result<List<ModelCenterTreeNodeParent>> listTree(){
        List<ModelCenterTreeNodeParent> resultList = modelCenterService.getModelCenterTree();
        return Result.success(resultList);
    }


    @PostMapping("listModel")
    @ResponseBody
    public Result<PageInfo<InfoModelCenterModelBaseInfo>> listModel(@RequestParam("startPage") int startPage,
                                                                @RequestParam("pageSize") int pageSize,
                                                                @Nullable @RequestParam("projId") String projId,
                                                                @Nullable @RequestParam("mainInfo") String mainInfo,
                                                                @Nullable @RequestParam("isDesc") Boolean isDesc,
                                                                @Nullable @RequestParam("modelStatus") Integer modelStatus){
        PageInfo<InfoModelCenterModelBaseInfo> list =
                modelCenterService.getDetailModelList(projId, mainInfo, isDesc, modelStatus, startPage, pageSize);
        return Result.success(list);
    }


    @PostMapping("updateModel")
    public Result<Integer> updateModel(@RequestParam("data") InfoModelCenterModelBaseInfo infoModelCenterModelBaseInfo){
        int result = modelCenterService.updateModel(infoModelCenterModelBaseInfo);
        return Result.success(result);
    }

    @PostMapping("deleteModel")
    public Result<Integer> deleteModel(@RequestParam("id") Long id){
        int result = modelCenterService.deleteModel(id);
        return Result.success(result);
    }

}

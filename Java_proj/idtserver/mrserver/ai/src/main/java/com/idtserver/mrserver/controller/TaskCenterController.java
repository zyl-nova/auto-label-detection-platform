package com.idtserver.mrserver.controller;

import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;
import com.idtserver.mrserver.result.Result;
import com.idtserver.mrserver.service.TaskCenterService;
import com.idtserver.mrserver.utils.FileValidator;
import com.idtserver.mrserver.utils.StoreMutipartFile;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Nullable;
import javax.annotation.Resource;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@CrossOrigin
@RestController
@RequestMapping("TaskCenter")
public class TaskCenterController {

    @Resource
    private TaskCenterService taskCenterService;

    @Value("${resources-path}")
    private  String prefix;

    @Value("${pics-path}")
    private String picPath;

    @Value("${models-path}")
    private  String modelsPath;


    @PostMapping("add")
    public Result<String> add(
                            @Nullable @RequestParam("taskName") String taskName,
                            @Nullable @RequestParam("projId") String projId,
                            @Nullable @RequestParam("des") String des,
                            @Nullable @RequestParam("preTrainModelId") String preTrainModelId,
                            @Nullable @RequestParam("sampleUrl") String sampleUrl,
                            @Nullable @RequestParam("modelOutputUrl") String modelOutputUrl,
                            @Nullable @RequestParam("learningRate") String learningRate,
                            @Nullable @RequestParam("epoch") String epoch,
                            @Nullable @RequestParam("batchSize") Integer batchSize,
                            @Nullable @RequestParam("testFilesUrl") String testFilesUrl,
                            @Nullable @RequestParam("sort") Integer sort,
                            @Nullable @RequestParam("createTime") Date createTime,
                            @Nullable @RequestParam("updateTime") Date updateTime,
                            @Nullable @RequestParam("logicalDelete")Integer logicalDelete,
                            @RequestParam("files") MultipartFile[] files){
        InfoTaskCenterTrainInfo infoTaskCenterTrainInfo = new InfoTaskCenterTrainInfo();
        infoTaskCenterTrainInfo.setTaskName(taskName);
        infoTaskCenterTrainInfo.setProjId(projId);
        infoTaskCenterTrainInfo.setDes(des);
        infoTaskCenterTrainInfo.setPreTrainModelId(preTrainModelId);
        infoTaskCenterTrainInfo.setSampleUrl(sampleUrl);
        infoTaskCenterTrainInfo.setModelOutputUrl(modelOutputUrl);
        infoTaskCenterTrainInfo.setLearningRate(learningRate);
        infoTaskCenterTrainInfo.setEpoch(epoch);
        infoTaskCenterTrainInfo.setBatchSize(batchSize);
        infoTaskCenterTrainInfo.setTestFilesUrl(testFilesUrl);
        infoTaskCenterTrainInfo.setSort(sort);
        infoTaskCenterTrainInfo.setCreateTime(createTime);
        infoTaskCenterTrainInfo.setUpdateTime(updateTime);
        infoTaskCenterTrainInfo.setLogicalDelete(logicalDelete);


        String fullPath = Paths.get(prefix + "/" +picPath).toAbsolutePath().toString();

        FileValidator fileValidator = new FileValidator();
        StoreMutipartFile storeMutipartFile = new StoreMutipartFile();


        //上传的图片zip压缩包如果有多个，先将所有解压缩的路径获取到，然后将所有解压缩的统一归并到一个文件夹中
        List<String> paths = new ArrayList<>();
        for(MultipartFile file : files){
            if(!file.isEmpty()){    //判断是否为zip文件
                boolean isZip = fileValidator.isZipFile(file);
                if(isZip){      //如果是zip文件则上传存储，并解压
                    String tmpStr = storeMutipartFile.uploadUnzip(fullPath, file);
                    paths.add(tmpStr);
                }
            }
        }

        //将多个文件夹中的文件归并到一个文件夹后，返回得到一个总的文件夹路径
        String mergedPath = null;
        try {
            mergedPath = storeMutipartFile.mergeFiles(fullPath, paths);
            infoTaskCenterTrainInfo.setSampleUrl(mergedPath);
        }catch (Exception e){
            e.printStackTrace();
        }
        //todo: 给算法程序提供mergedPath

        // 新建模型存储路径，存储模型的路径和图片的存储路径是不一样的
        String modelStorePath = Paths.get(prefix + "/" + modelsPath).toAbsolutePath().toString();
        Long result = taskCenterService.addNewTask(infoTaskCenterTrainInfo, modelStorePath);
        return Result.success(Long.toString(result));
    }

    @PostMapping("list")
    public Result<PageInfo<InfoTaskCenterTrainInfo>> list(@RequestParam("startPage") int startPage,
                                                          @RequestParam("pageSize") int pageSize,
                                                          @Nullable @RequestParam("mainInfo") String mainInfo,
                                                          @Nullable @RequestParam("isDesc") Boolean isDesc,
                                                          @Nullable @RequestParam("modelStatus") Integer modelStatus){
        PageInfo<InfoTaskCenterTrainInfo> list =
                taskCenterService.getDetailModelList(mainInfo, isDesc, modelStatus, startPage, pageSize);
        return Result.success(list);
    }

    @PostMapping("update")
    public Result<Integer> update(@RequestParam("data") InfoTaskCenterTrainInfo infoTaskCenterTrainInfo){
        int reuslt = taskCenterService.updateTask(infoTaskCenterTrainInfo);
        return Result.success(reuslt);
    }

    @PostMapping("delete")
    public Result<Integer> delete(@RequestParam("id") Long id){
        int result = taskCenterService.deleteTask(id);
        return Result.success(result);
    }
}

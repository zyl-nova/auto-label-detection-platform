package com.idtserver.mrserver.service.impl;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.idtserver.mrserver.dto.FileManager;
import com.idtserver.mrserver.dto.InfoModelCenterModelBaseInfo;
import com.idtserver.mrserver.dto.InfoTaskCenterTrainInfo;
import com.idtserver.mrserver.mapper.FileManagerMapper;
import com.idtserver.mrserver.mapper.ModelCenterMapper;
import com.idtserver.mrserver.mapper.TaskCenterMapper;
import com.idtserver.mrserver.result.Result;
import com.idtserver.mrserver.service.FileManagerService;
import com.idtserver.mrserver.service.TaskCenterService;
import com.idtserver.mrserver.utils.SnowflakeIdGenerator;
import com.idtserver.mrserver.utils.StoreMutipartFile;
import com.idtserver.mrserver.utils.VideoFilesExtractor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;

@Service
public class FileManagerServiceImpl implements FileManagerService {

    @Resource
    FileManagerMapper fileManagerMapper;

    @Value("${pics-path}")
    private  String picsPath;

    @Value("${resources-path}")
    private  String prefix;




    @Override
    public PageInfo<FileManager> getFileManagerList(String projId,
                                                    String mainInfo,
                                                    Boolean isDesc,
                                                    int pageNum,
                                                    int pageSize,
                                                    int fileType) {
        PageHelper.startPage(pageNum, pageSize);
        List<FileManager> list = fileManagerMapper.getFileManagerRecordList(projId, mainInfo, isDesc, fileType);

        return new PageInfo<>(list);
    }

    @Override
    public Long addNewFileManagerRecord(FileManager fileManager, String filePath) {
        //图片存储文件夹
        String storePath = prefix + "/" + picsPath;
        //首先将记录状态设置为0
        SnowflakeIdGenerator idGenerator = new SnowflakeIdGenerator(0, 0);
        fileManager.setId(Long.toString(idGenerator.nextId()));
        fileManager.setLogicalDelete(0);
        fileManager.setUpdateTime(new Date());
        fileManager.setCreateTime(new Date());
        fileManager.setStatus(0);
        fileManagerMapper.createFileManagerRecord(fileManager);
        File file = new File(filePath);
        if(fileManager.getOriginalFileType().equals(0)){
            String imageFileType = file.getName().substring(file.getName().lastIndexOf(".") + 1).toLowerCase();
            if(imageFileType.equals("zip")){
                //将状态设置为1
                fileManager.setStatus(1);
                fileManagerMapper.updateFileManagerRecord(fileManager);
                String storeImgsPathDirName = file.getName().substring(0, file.getName().lastIndexOf(".")) + "_o" ;

                Path path = Paths.get(storePath);
                File storeImgsPathDir = new File(path.toAbsolutePath().toString() + '/' + storeImgsPathDirName);
                if (!storeImgsPathDir.exists()) {
                    storeImgsPathDir.mkdirs();
                }
                try{
                    StoreMutipartFile storeMutipartFile = new StoreMutipartFile();
                    storeMutipartFile.unzip(file.getAbsolutePath(), storeImgsPathDir.getAbsolutePath());
                    //将状态设置为2,完成
                    fileManager.setStatus(2);
                    fileManager.setDisposedFileStoreUrl(storeImgsPathDir.getAbsolutePath());
                    fileManagerMapper.updateFileManagerRecord(fileManager);
                }catch (Exception e){
                    e.printStackTrace();
                }
            } else {
                fileManager.setStatus(2);
                fileManagerMapper.updateFileManagerRecord(fileManager);
            }
        }else if(fileManager.getOriginalFileType().equals(1)){
            String storeImgsPathDirName = file.getName().substring(0, file.getName().lastIndexOf(".")) + "_o" ;

            Path path = Paths.get(storePath);
            File storeImgsPathDir = new File(path.toAbsolutePath().toString() + '/' + storeImgsPathDirName);

            if (!storeImgsPathDir.exists()) {
                storeImgsPathDir.mkdirs();
            }
            fileManager.setDisposedFileStoreUrl(storeImgsPathDir.getPath());
            fileManager.setStatus(1);
            fileManagerMapper.updateFileManagerRecord(fileManager);
            VideoFilesExtractor extractor = new VideoFilesExtractor(fileManager,
                    filePath,
                    storeImgsPathDir.getAbsolutePath(),
                    3,
                    fileManagerMapper);
            extractor.run();

        }
        return 0l;
    }

    @Override
    public int updateFileManagerRecord(FileManager fileManager) {
        fileManager.setUpdateTime(new Date());
        fileManagerMapper.updateFileManagerRecord(fileManager);
        return 0;
    }

    @Override
    public int deleteFileManagerRecord(Long modelId) {
        fileManagerMapper.deleteFileManagerRecord(modelId);
        return 0;
    }
}

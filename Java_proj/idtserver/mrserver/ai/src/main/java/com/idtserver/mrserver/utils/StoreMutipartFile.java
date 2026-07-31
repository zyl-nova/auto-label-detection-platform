package com.idtserver.mrserver.utils;

import lombok.Data;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveInputStream;
import org.apache.commons.io.IOUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@Data
public class StoreMutipartFile {



    public String uploadUnzip(String zipStorePath, MultipartFile file){

        try{
            //1.获取源文件的输入流
            InputStream inputStream = file.getInputStream();
            //2.获取源文件类型，文件后缀名
            String originalFilename = file.getOriginalFilename();
            //3.定义上传后的目标文件名（为了避免文件名称重复，此时使用UUID）
            String UUIDFileName = UUID.randomUUID().toString();
            String newFileDirName = UUIDFileName + "_" +originalFilename.substring(0, originalFilename.lastIndexOf("."));
            String newFilename = UUIDFileName + "_" + originalFilename;
            //4.通过上传路径得到上传的文件夹
            File fileStore = new File(zipStorePath);
            //4.1.若目标文件夹不存在，则创建
            if(!fileStore.exists()){ //判断目标文件夹是否存在
                fileStore.mkdirs();  //4.2.不存在，则创建文件夹
            }
            //5.根据目标文件夹和目标文件名新建目标文件（上传后的文件）
            File newFile = new File(zipStorePath, newFilename); //空的目标文件
            //6.根据目标文件的新建其输出流对象
            FileOutputStream outputStream = new FileOutputStream(newFile);
            //7.完成输入流到输出流的复制
            IOUtils.copy(inputStream, outputStream);
            //8.关闭流（先开后关）
            outputStream.close();
            inputStream.close();

            //9.按照文件名，在当前文件解压
            unzip( zipStorePath + "/" + newFilename, "/" + zipStorePath + "/" + newFileDirName);
            return  zipStorePath + "/" + newFileDirName;
        }catch (IOException e){
            e.printStackTrace();
            return "Error";
        }
    }

    public  void unzip(String zipFilePath, String destDir) throws IOException {

        File zipFile = new File(zipFilePath);
        try (ZipArchiveInputStream inputStream = getZipFile(zipFile)) {
            File pathFile = new File(destDir);
            if (!pathFile.exists()) {
                pathFile.mkdirs();
            }
            ZipArchiveEntry entry = null;
            while ((entry = inputStream.getNextZipEntry()) != null) {
                if (entry.isDirectory()) {
                    File directory = new File(destDir, entry.getName());
                    directory.mkdirs();
                } else {
                    OutputStream os = null;
                    try {
                        os = new BufferedOutputStream(new FileOutputStream(new File(destDir, entry.getName())));
                        //输出文件路径信息
                        IOUtils.copy(inputStream, os);
                    } finally {
                        IOUtils.closeQuietly(os);
                    }
                }
            }

        }
    }

    public static ZipArchiveInputStream getZipFile(File zipFile)  {

        try{
            return new ZipArchiveInputStream(new BufferedInputStream(new FileInputStream(zipFile)));
        }catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }



    //将多个文件夹的文件，归并到一个文件夹中
    public String mergeFiles(String storePath, List<String> paths) throws IOException {

        // 创建存储路径文件夹
        File storeFolder = new File(storePath);
        if (!storeFolder.exists()) {
            storeFolder.mkdirs();
        }

        //创建新的文件夹（为了避免文件名称重复，此时使用UUID）
        String UUIDFileName = UUID.randomUUID().toString();
        //创建新的文件夹路径
        File newFolder = new File(storePath, UUIDFileName); //空的目标文件



        // 遍历文件夹路径列表
        for (String path : paths) {
            File sourceFolder = new File(path);
            // 检查源文件夹是否存在
            if (sourceFolder.exists() && sourceFolder.isDirectory()) {
                // 获取源文件夹中的文件列表
                File[] files = sourceFolder.listFiles();
                if (files != null) {
                    // 遍历文件列表并复制到存储路径
                    for (File file : files) {
                        Path source = file.toPath();
                        Path dest = newFolder.toPath();
                        // 使用 Files.copy() 方法进行复制
                        Files.copy(source, dest, StandardCopyOption.REPLACE_EXISTING);
                    }
                }
            } else {
                System.out.println("警告：路径 " + path + " 不是一个有效的文件夹路径");
            }
        }

        return newFolder.getAbsolutePath();

    }

    //使用UUID创建一个新的模型存储空文件夹
    public String createNewFile(String storeFile) throws IOException {
        String UUIDFileName = UUID.randomUUID().toString();
        String returPath = storeFile + "/" + UUIDFileName;
        File pathFile = new File(returPath);
        if (!pathFile.exists()) {
            pathFile.mkdirs();
        }
        return returPath;
    }
}

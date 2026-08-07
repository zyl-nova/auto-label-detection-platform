<template>
    <div class="labeling-layout">
        <div class="labeling-aside">
            <!-- 创建形状开始 -->
            <div class="create-shape">
                <span>创建形状</span>
                <div class="create-shape-button">
                    <button v-for="item in drawShape" :class="{ active: currentWorkModel === item.workModel }" :title="item.name" @click="changeModel(item.workModel)">
                        <svg-icon :iconName="item.iconName"  ></svg-icon>
                    </button>
                </div>
            </div>
            <!-- 创建形状结束 -->

            <!-- 工具箱开始 -->
            <div class="tool-box">
                <span>工具箱</span>
                <div class="tool-box-button">
                    <button v-for="item in toolboxButton" :class="{ active: currentWorkModel === item.workModel }" :title="item.name" @click="changeModel(item.workModel)">
                        <svg-icon :iconName="item.iconName"  ></svg-icon>
                    </button>
                </div>
            </div>
            <!-- 工具箱结束 -->
        </div>

            
        <div class="label-main">
            <el-breadcrumb :separator-icon="ArrowRight" style="padding: 2% 0 0 2%;">
                <el-breadcrumb-item :to="{ path: '/label' }">标注</el-breadcrumb-item>
                <el-breadcrumb-item>标注任务</el-breadcrumb-item>
            </el-breadcrumb>
            <!-- 图片信息与切换开始 -->
            <div class="switch-img" >
                <button @click="switchImage(-1)">
                    <svg-icon iconName="icon-arrow-left"></svg-icon>
                </button>
                <div style="display: flex;flex-direction:column;justify-content: center;">
                    <span>{{ currentFile?.name || '暂无图片' }}</span>
                    <span>{{ currentFiles.length ? currentFileIndex + 1 : 0 }}/{{ currentFiles.length }}</span>
                </div>
                <button @click="switchImage(1)">
                    <svg-icon iconName="icon-arrow-right"></svg-icon>
                </button>
            </div>
            <!-- 图片信息与切换结束 -->
            <!-- 图像展现及标注区域 开始-->
            <div class="label-canvas" ref="canvasParent">
                <canvas  ref="canvas" ></canvas>
            </div>
            <!-- 图像展现及标注区域 结束-->
            <div class="label-button">
                <!-- 退出按钮 -->
                <button class="exit-button" @click="">退出</button>
                <!-- 保存按钮 -->
                <button class="save-button"  @click="handleSave">保存</button>
            </div>
        </div>

        <div class="labeling-result-aside">
            <!-- 标签列表开始 -->
            <div class="label-list">
                <div class="head">标签列表（{{labelList.length}}）</div>
                <div class="content">
                    <div v-for="(item, index) in labelList" @click="selectLabel(item.index)">
                        <span style="padding-right: 1em;">{{ index+1 }}</span>
                        <svg-icon iconName="icon-24gf-circle" :style="{color:item.color,padding:'0 0.5em 0 0 '}"></svg-icon>
                        <span>{{ item.cname }}</span>
                    </div>
                </div>
            </div>
            <!-- 标签列表结束 -->
            <!-- 标注结果开始 -->
            <div class="label-result">
                <div class="head">标注结果（{{labelResults.length}}）</div>
                <div class="content">
                    <el-row style="color: white;" >
                        <el-col :span="2"></el-col>
                        <el-col :span="10">名称</el-col>
                        <el-col :span="4">修改</el-col>
                        <el-col :span="4">删除</el-col>
                        <el-col :span="4">显隐</el-col>
                    </el-row>
                    <el-row v-for="(item, index) in labelResults" style="color: white;">
                        <el-col :span="10">
                            <span style="padding-right: 1em;">{{ index+1 }}</span> 
                            <svg-icon iconName="icon-24gf-circle" :style="{color:item.baseInfo.color,padding:'0 0.5em 0 0 '}"></svg-icon>
                            <span>{{ item.baseInfo.cname }}</span>
                        </el-col>
                        <el-col :span="2"></el-col>
                        <el-col :span="4" >
                            <svg-icon iconName="icon-biji"  @click="handleEdit(item)" style="cursor: pointer;"></svg-icon>
                        </el-col>
                        <el-col :span="4">
                            <svg-icon iconName="icon-shanchu"  @click="handleDelete(item)" style="cursor: pointer;"></svg-icon>
                        </el-col>
                        <el-col :span="4">
                            <svg-icon iconName="icon-kejian"  @click="handleHide(item)" style="cursor: pointer;"></svg-icon>
                        </el-col>
                    </el-row>
                </div>
            </div>
            <!-- 标注结果结束 -->
            <!-- 文件列表开始 -->
            <div class="file-list">
                <div class="head">文件列表</div>
                <div class="content">
                    <!-- 搜索、筛选 -->
                    <el-row>
                        <el-col :span="9">
                            <div class="search-sift">
                                <svg-icon v-show="hideCircle" style="padding-left: 2%;fill: rgb(51, 53, 54); stroke-width: 10%; stroke: white;"  iconName="icon-24gf-circle"></svg-icon>
                                <input style="border:0px;background-color: transparent;width: 70%;" type="text" v-model="searchQuery" placeholder="按文件名称检索" @focus="dealFocus" @blur="dealBlur">
                            </div>
                        </el-col>
                        <el-col :span="6" :offset="1">
                            <div class="is-label">
                                <el-select :teleported="false"  v-model="fileListLabelTag" placeholder="是否标注" >
                                    <el-option
                                        v-for="item in fileListLabelOptions"
                                        :key="item.value"
                                        :label="item.label"
                                        :value="item.value"
                                    />
                                </el-select>
                            </div>
                        </el-col>
                        <el-col :span="6" :offset="1">
                            <div class="is-label">
                                <el-select :teleported="false"  v-model="reviewResultslTag" placeholder="审核结果" >
                                    <el-option
                                        v-for="item in reviewResultsOptions"
                                        :key="item.value"
                                        :label="item.label"
                                        :value="item.value"
                                    />
                                </el-select>
                            </div>
                        </el-col>
                    </el-row>
                    
                    <!-- 列表 -->
                    <div class="table-data">
                        <el-table 
                        :teleported="false"
                        :data="fileListDataTable" 
                        style="width: 100%"
                        :header-cell-style=changeHeaderCellStyle
                        :cell-style=changeCellStyle
                        @row-click="selectFileRow"
                        >
                            <el-table-column prop="fileName" label="文件名"  />
                            <el-table-column prop="isLabeled" label="是否标注"  />
                            <el-table-column prop="reviewResult" label="审核结果" />
                        </el-table>
                    </div>
                </div>
            </div>
            <!-- 文件列表结束 -->
        </div>
    </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import allStore from '@/stores'
import { ArrowRight } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useRoute } from 'vue-router'
import { fabric  } from 'fabric'
import { cloneDeep  } from 'lodash';
import { getImageAnnotation, saveImageAnnotation } from '@/api/imageLabel'
import { listPreviewImages, previewImageUrl } from '@/api/fileManager'
import type { ManagedFile } from '@/stores/businessStore'



//统一导出pinia
const {aside, business} = allStore()
const route = useRoute()
const currentFileIndex = ref(0)
const currentTaskId = computed(() => Number(route.query.taskId || 0))
const routeFileId = computed(() => Number(route.query.fileId || 0))
const routeBackendId = computed(() => String(route.query.backendId || route.query.fileId || ''))
const currentTask = computed(() => business.labelTasks.find((item) => item.id === currentTaskId.value))
type LabelingFile = ManagedFile & { imageIndex: number }
const currentFiles = ref<LabelingFile[]>([])

const loadTaskImages = async () => {
    const taskFileIds = currentTask.value?.fileIds || (routeFileId.value ? [routeFileId.value] : [])
    const files = taskFileIds
        .map((id) => business.files.find((file) => file.id === id))
        .filter(Boolean) as typeof business.files

    if (!files.length && routeFileId.value) {
        files.push({
            id: routeFileId.value,
            backendId: routeBackendId.value,
            name: `文件${routeFileId.value}`,
            type: '图像',
            projectId: 0,
            projectName: '',
            creator: '',
            uploadTime: '',
            source: '',
            url: `/api/AIModuleServer/FileManager/preview?id=${routeFileId.value}`,
        })
    }

    const images: LabelingFile[] = []
    for (const file of files.filter((item) => item.type === '图像')) {
        const backendId = file.backendId || String(file.id)
        try {
            const names = await listPreviewImages(backendId)
            if (names.length) {
                names.forEach((name, imageIndex) => {
                    images.push({
                        ...file,
                        backendId,
                        imageIndex,
                        imageName: name,
                        name,
                        url: previewImageUrl(backendId, imageIndex),
                    })
                })
                continue
            }
        } catch (error) {
            console.warn('读取压缩包图片列表失败，将按单张图片载入。', error)
        }
        images.push({ ...file, backendId, imageIndex: 0 })
    }
    currentFiles.value = images
}
const currentFile = computed(() => currentFiles.value[currentFileIndex.value])


const drawShape = ref([
    {
        name: '直线标注',
        iconName: 'icon-edit-line',
        workModel: 200
    },
    {
        name: '矩形标注',
        iconName: 'icon-juxing',
        workModel: 201
    },
    {
        name: '圆形标注',
        iconName: 'icon-big-circle',
        workModel: 202
    },
    {
        name: '多边形标注',
        iconName: 'icon-huaduobianxing',
        workModel: 203
    },
])

const toolboxButton = ref([
    {
        name: '复制',
        iconName: 'icon-fuzhi',
        workModel: 100
    },
    {
        name: '缩小',
        iconName: 'icon-suoxiao',
        workModel: 101
    },
    {
        name: '放大',
        iconName: 'icon-fangda',
        workModel: 102
    },
    {
        name: '选择、移动和缩放',
        iconName: 'icon-zhuashou',
        workModel: 103
    },
    {
        name: '撤销',
        iconName: 'icon-fanhui',
        workModel: 104
    },
    
])


//标签列表
/**
 * interface labelType{
    cname:string,
    color:string,
    ename:string,
    index:number
}
 */
interface labelType{
    cname:string,
    color:string,
    ename:string,
    index:number
}
const labelList = ref<labelType[]>([])
const currentLabelTypeIndex = ref(0) //当前选择的标签
//颜色生成函数
const generateRandomColor  = () => {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)]
        
    }
    return color;
}

const generateColors = () => {
    const taskLabels = currentTask.value?.labels?.length ? currentTask.value.labels : ['wire', 'insulator']
    labelList.value = []
    for (let i = 0; i < taskLabels.length; i++) {
        let colorTmp = generateRandomColor()
        let l:labelType = {
            cname: taskLabels[i],
            ename: taskLabels[i],
            color:colorTmp,
            index:i
        } 
        labelList.value.push(l)
    }
}

const selectLabel = (labelType:number) => {
    currentLabelTypeIndex.value = labelType
}

/**
 * 标注结果
 * interface storeObj  {
    index:string
    baseInfo:labelType
    shapeType:number
    fabricObj:fabric.Object
    }
*/

interface storeObj  {
    index:string
    baseInfo:labelType
    shapeType:number
    fabricObj:fabric.Object
}
interface StoredAnnotation {
    index:string
    baseInfo:labelType
    shapeType:number
    fabricObj:any
}
interface StoredAnnotationDocument {
    version:2
    canvas:{width:number, height:number}
    image:{left:number, top:number, width:number, height:number}
    annotations:StoredAnnotation[]
}
const labelResults = ref<storeObj[]>([])
 //当前绘制图形的形状 200:绘制直线 201：绘制矩形 202：绘制圆 203：绘制多边形
const currentDrawType = ref(202) 


//文件列表
const hideCircle = ref(true)
const searchQuery = ref('')
const dealFocus = () => {
    hideCircle.value = false
}

const dealBlur = () => {
    hideCircle.value = true
}
const fileListLabelTag = ref()
const reviewResultslTag = ref()

const fileListLabelOptions = [
  {
    value: 'true',
    label: '是',
  },
  {
    value: 'false',
    label: '否',
  },
  
]

const reviewResultsOptions = [
  {
    value: '1',
    label: '待审核',
  },
  {
    value: '2',
    label: '通过',
  },
  {
    value: '3',
    label: '未通过',
  },
  
]

const labeledImageKeys = ref<string[]>([])
const imageKey = (file: LabelingFile) => `${file.backendId || file.id}:${file.imageIndex}`

const fileListDataTable = computed(() => currentFiles.value.map((file, rowIndex) => ({
    rowIndex,
    fileName: file.name,
    isLabeled: labeledImageKeys.value.includes(imageKey(file)) ? '是' : '否',
    reviewResult: labeledImageKeys.value.includes(imageKey(file)) ? '待审核' : '待标注',
})))

const changeHeaderCellStyle = () =>{
    let styleObject = {
        'background-color':'rgb(46, 47, 70) !important',
        'border':'0 solid transparent',
        'color':'rgb(139, 140, 153)',
        'padding':'0.3em 0 0 0'
    }
    return styleObject
}

const changeCellStyle = () => {
    let styleObject = {
        'background-color':'rgb(46, 47, 70) !important',
        'border':'none !important',
        'color':'rgb(139, 140, 153)',
        'font-size':'0.7em',
        'padding':'0.3em 0 0 0'
    }
    return styleObject
}




/**
 * 当前图形存档
 */
async function save(){
    let l = cloneDeep(labelResults.value)
    history.push(l)
}



//回撤功能
const undo = async() => {
    let lastState
    if(history.length == 1){
        history.pop();
        lastState = [];
    }else{
        history.pop();
        lastState = history[history.length - 1]
    }

    fabricCanvas.getObjects().map((o:any) => {
        fabricCanvas.remove(o);
    })
    lastState = cloneDeep(lastState)
    
    // 根据保存的状态恢复对象
    if(lastState){
       
        labelResults.value = []
        lastState.map((o:any) => {
            labelResults.value.push(o)
        })
        let tmpArr:any[] = []
        lastState.map((o:any) => {
            let k = o.fabricObj.toObject()
            k.index = o.index
            tmpArr.push(k) 
        })
        
        // 假设 lastState 是你保存的状态数组，包含多个 label 结构
        fabric.util.enlivenObjects(
            tmpArr, // 仅提取 fabricObj 数组
            
            function (fabricObjects:any) {
                fabricObjects.forEach((fabricObj:any) => {
                    fabricCanvas.add(fabricObj);
                });
                // 渲染画布
                fabricCanvas.renderAll();
                
            },''
        )

    }
}


//在canvas上绘制图形
const canvas = ref()
const canvasParent = ref()
const imageAddr = ref()
const history:any[] = [];  // 历史记录

const annotationStorageKey = (file = currentFile.value) => {
    const taskId = currentTaskId.value || 'local'
    const fileId = file?.backendId || file?.id || routeBackendId.value || 'unknown'
    const imageIndex = file?.imageIndex || 0
    return `auto-label-detection:annotations:${taskId}:${fileId}:${imageIndex}`
}

const loadLabeledStates = async () => {
    const keys = await Promise.all(currentFiles.value.map(async (file) => {
        if (localStorage.getItem(annotationStorageKey(file)) !== null) {
            return imageKey(file)
        }
        if (!currentTaskId.value) return ''
        try {
            const record = await getImageAnnotation(
                currentTaskId.value,
                file.backendId || file.id,
                file.imageIndex,
            )
            return record ? imageKey(file) : ''
        } catch (error) {
            return ''
        }
    }))
    labeledImageKeys.value = keys.filter(Boolean)
}

//生成id
const generateId = () => {
    return new Date().getTime().toString(36) + '-' + Math.random().toString(36).slice(2, 9)
}

/**当前工作模式 
 * 100:复制 101：缩小 102:放大 103：拖拽 104:撤销
 * 200:绘制直线 201：绘制矩形 202：绘制圆 203：绘制多边形
 */
const currentWorkModel = ref(0)
let fabricCanvas:any
let isDrawing = false
let isDragging = false

let rect:any
let line:any
let circle:any
let polygon:any

let rectPoints:number[] = []
let linePoints:number[] = []
let circlePoints:number[] = []
const polygonPoints = ref<{x:number, y:number}[]>([])
const polygonLines = ref<fabric.Line[]>([])
const polygonTmp = ref<fabric.Polygon>()

let zoomStep = 1.2
//画布上次的位置
let canvasLastPosX:any
let canvasLastPosY:any
//放大缩小比例
const scale = ref()
//加载图片对象
let imageObj:any = null

const getImageBounds = () => {
    if (!imageObj) return { left: 0, top: 0, width: 0, height: 0, right: 0, bottom: 0 }
    const left = imageObj.left || 0
    const top = imageObj.top || 0
    const width = imageObj.getScaledWidth?.() || (imageObj.width || 0) * (imageObj.scaleX || 1)
    const height = imageObj.getScaledHeight?.() || (imageObj.height || 0) * (imageObj.scaleY || 1)
    return { left, top, width, height, right: left + width, bottom: top + height }
}

const setAnnotationEditable = (object:any, editable:boolean) => {
    object.set({
        selectable: editable,
        evented: editable,
        hasControls: editable,
        hasBorders: editable,
        lockRotation: true,
        lockScalingFlip: true,
        transparentCorners: false,
        cornerColor: '#ffffff',
        cornerStrokeColor: '#2563eb',
        borderColor: '#2563eb',
        cornerStyle: 'circle',
        cornerSize: 12,
        touchCornerSize: 22,
        padding: 2,
    })
    object.setControlsVisibility?.({ mtr: false })
    object.setCoords()
}


//切换成移动模式
const changeModel = (workModel:number) =>{
    let objects = fabricCanvas.getObjects();
    
    switch (workModel){
        //100:复制 101：缩小 102:放大 103：拖拽 104:撤销
        case 100:
            break
        case 101:
            break
        case 102:
            break
        case 103:
            currentWorkModel.value = workModel
            objects.forEach((o:any) => {
                setAnnotationEditable(o, true)
            })
            fabricCanvas.defaultCursor = 'default'
            fabricCanvas.hoverCursor = 'move'
            break
        case 104:
            undo()
            break
        //200:绘制直线 201：绘制矩形 202：绘制圆 203：绘制多边形
        case 200:

        case 201:

        case 202:

        case 203:
            currentDrawType.value = workModel
            currentWorkModel.value = workModel
            objects.forEach((o:any) => {
                setAnnotationEditable(o, false)
            })
            fabricCanvas.discardActiveObject()
            fabricCanvas.defaultCursor = 'crosshair'
            fabricCanvas.renderAll()
            break
    }    
}


//载入图片
const loadImage = (url:string) => {
    imageAddr.value = url.startsWith('/api/') || url.startsWith('http') ? url : new URL(url, import.meta.url).href
    fabric.Image.fromURL(imageAddr.value, (img: any) => {
        let width = canvasParent.value.clientWidth
        let height = canvasParent.value.clientHeight
        if(width < img.width || height < img.height){
            //计算缩放比例
            let scaleX = width / img.width
            let scaleY = height / img.height
            scale.value = Math.min(scaleX, scaleY)
            //缩放背景图片
            img.scaleToWidth(img.width * scale.value)
            img.scaleToHeight(img.height * scale.value)
        }else{
            img.left = (width - img.width) / 2
            img.top = (height - img.height) / 2
        }
        imageObj = img
        fabricCanvas.clear()
        fabricCanvas.setBackgroundImage(img, async () => {
            await restoreSavedAnnotations()
            fabricCanvas.renderAll()
        })
        
    })
}

const normalizeAnnotationText = (value:any) => {
    if (!value) return ''
    return typeof value === 'string' ? value : JSON.stringify(value)
}

const parseStoredAnnotations = (raw:string) => {
    const saved = JSON.parse(raw) as StoredAnnotation[] | StoredAnnotationDocument
    return Array.isArray(saved) ? saved : saved.annotations || []
}

const restoreSavedAnnotations = async () => {
    let raw = ''
    const file = currentFile.value
    let hasSavedRecord = false
    if (currentTaskId.value && file?.id) {
        try {
            const record = await getImageAnnotation(
                currentTaskId.value,
                file.backendId || file.id,
                file.imageIndex,
            )
            hasSavedRecord = Boolean(record)
            raw = normalizeAnnotationText(record?.labelData)
        } catch (error) {
            raw = ''
        }
    }
    if (!raw) {
        const localRecord = localStorage.getItem(annotationStorageKey(file))
        hasSavedRecord = hasSavedRecord || localRecord !== null
        raw = localRecord || ''
    }
    if (hasSavedRecord && file) {
        const key = imageKey(file)
        if (!labeledImageKeys.value.includes(key)) {
            labeledImageKeys.value = [...labeledImageKeys.value, key]
        }
    }
    if (!raw) return

    try {
        const annotations = parseStoredAnnotations(raw)
        if (!annotations.length) return

        labelResults.value = []
        const fabricObjects = annotations.map((item) => ({
            ...item.fabricObj,
            index: item.index,
        }))

        fabric.util.enlivenObjects(
            fabricObjects,
            function (objects:any[]) {
                objects.forEach((object:any, index:number) => {
                    const saved = annotations[index]
                    object.index = saved.index
                    setAnnotationEditable(object, currentWorkModel.value === 103)
                    fabricCanvas.add(object)
                    labelResults.value.push({
                        index: saved.index,
                        baseInfo: saved.baseInfo,
                        shapeType: saved.shapeType,
                        fabricObj: object,
                    })
                })
                save()
                fabricCanvas.renderAll()
            },
            '',
        )
    } catch (error) {
        console.error(error)
        ElMessage.warning('读取本地标注缓存失败，可重新标注后保存')
    }
}

const loadCurrentFile = () => {
    labelResults.value = []
    history.length = 0
    const file = currentFile.value
    if (file?.url) {
        loadImage(file.url)
        return
    }
    loadImage('../../assets/image/kj.jpg')
}

const switchImage = (step:number) => {
    if (!currentFiles.value.length) return
    currentFileIndex.value = (currentFileIndex.value + step + currentFiles.value.length) % currentFiles.value.length
    loadCurrentFile()
}

const selectFileRow = (row: { rowIndex: number }) => {
    if (row.rowIndex === currentFileIndex.value) return
    currentFileIndex.value = row.rowIndex
    loadCurrentFile()
}

//滚轮图片缩放
const canvasZoomBywheel = () => {
    
}

//图片放大
const canvasZoomEnlarge = () => {
    fabricCanvas.on('mouse:down', (opt:any) =>{
        

        let zoom = fabricCanvas.getZoom() // 获取画布当前缩放值
        zoom *=  zoomStep
        if(zoom < 1){
            zoom = 1
        }
        fabricCanvas.zoomToPoint({
            x: opt.e.offsetX,
            y: opt.e.offsetY
        }, zoom)
    })
}

//图片缩小
const canvasZoomShrink = () => {
    fabricCanvas.on('mouse:down', (opt:any) =>{
        let zoom = fabricCanvas.getZoom() // 获取画布当前缩放值
        zoom /= zoomStep
        if(zoom < 1){
            zoom = 1
        }
        fabricCanvas.zoomToPoint({
            x: opt.e.offsetX,
            y: opt.e.offsetY
        }, zoom)
    })
}

const deleteSelectedObject  = () => {
    let activeObj = fabricCanvas.getActiveObject()

    if(activeObj){
        fabricCanvas.remove(activeObj)
        labelResults.value = labelResults.value.filter((o:any) => o.index !== activeObj.index)
    }
    save()
}

const handleCanvasKeydown = (event:KeyboardEvent) => {
    const target = event.target as HTMLElement | null
    if (target?.matches('input, textarea, select') || target?.isContentEditable) return

    if(event.key === 'Delete' || event.key === 'Backspace'){
        event.preventDefault()
        deleteSelectedObject()
        return
    }

    const movement:Record<string, [number, number]> = {
        ArrowLeft: [-1, 0],
        ArrowRight: [1, 0],
        ArrowUp: [0, -1],
        ArrowDown: [0, 1],
    }
    const direction = movement[event.key]
    const activeObject = fabricCanvas?.getActiveObject()
    if (!direction || !activeObject || currentWorkModel.value !== 103) return

    event.preventDefault()
    const distance = event.shiftKey ? 10 : 1
    activeObject.set({
        left: (activeObject.left || 0) + direction[0] * distance,
        top: (activeObject.top || 0) + direction[1] * distance,
    })
    limitObjectToBackground(activeObject)
    fabricCanvas.requestRenderAll()
    save()
}

const handleResize = () => {
    if(fabricCanvas ){
        fabricCanvas.setDimensions({width:canvasParent.value.clientWidth, height:canvasParent.value.clientHeight})
    }
}

const handleSave = async () => {
    if (!currentFile.value) {
        ElMessage.warning('当前没有可保存的图片')
        return
    }

    const annotations: StoredAnnotation[] = labelResults.value.map((item) => ({
        index: item.index,
        baseInfo: item.baseInfo,
        shapeType: item.shapeType,
        fabricObj: item.fabricObj.toObject(['index']),
    }))
    const annotationDocument: StoredAnnotationDocument = {
        version: 2,
        canvas: {
            width: fabricCanvas.getWidth(),
            height: fabricCanvas.getHeight(),
        },
        image: {
            left: imageObj?.left || 0,
            top: imageObj?.top || 0,
            width: imageObj?.getScaledWidth?.() || imageObj?.width || 0,
            height: imageObj?.getScaledHeight?.() || imageObj?.height || 0,
        },
        annotations,
    }
    const annotationData = JSON.stringify(annotationDocument)

    localStorage.setItem(annotationStorageKey(currentFile.value), annotationData)

    if (currentTaskId.value && currentFile.value.id) {
        try {
            await saveImageAnnotation({
                taskId: currentTaskId.value,
                fileId: currentFile.value.backendId || currentFile.value.id,
                imageIndex: currentFile.value.imageIndex,
                labelData: annotationData,
                labelList: JSON.stringify(labelList.value),
                picStoreUrl: currentFile.value.url || '',
            })
        } catch (error) {
            ElMessage.warning('后端暂不可用，标注结果已先保存到本地缓存')
        }
    }

    const savedKey = imageKey(currentFile.value)
    if (!labeledImageKeys.value.includes(savedKey)) {
        labeledImageKeys.value = [...labeledImageKeys.value, savedKey]
    }

    if (currentTask.value) {
        business.updateLabelTask(currentTask.value.id, {
            status: '待审核',
            progress: 80,
        })
    }

    ElMessage.success(`已保存 ${annotations.length} 个标注结果`)
}



//绘制直线
const drawLine = (pointer:number[]) => {
    let currentId = generateId()
    fabricCanvas.remove(line)
    let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]
    line = Object.assign(new fabric.Line(pointer, {
        fill:currentBaseInfo.color+'80',
        selectable: false,
        strokeWidth: 5,
        stroke: currentBaseInfo.color+'80',//笔触颜色
    }), {index:currentId})
    
    let labelStoreObj:storeObj = {index:currentId, baseInfo:currentBaseInfo, shapeType:200, fabricObj: line}

    
    fabricCanvas.add(line)
    return labelStoreObj
}

//绘制矩形
const drawRect = (pointer:any) => {

    fabricCanvas.remove(rect)
    let currentId = generateId()
    let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]

    let width =  pointer.x - rectPoints[0] 
    let height = pointer.y - rectPoints[1] 

    if(width > 0 && height > 0){
        rect = Object.assign(new fabric.Rect({
            left: rectPoints[0],
            top: rectPoints[1],
            originX:'left',
            originY:'top',
            width: width,
            height: height,
            angle: 0,
            fill: currentBaseInfo.color+'20',
            stroke: currentBaseInfo.color,
            strokeWidth: 2,
            strokeUniform: true,
            transparentCorners: false,
            selectable: false,
            
        }), {index:currentId})
    }else if(width < 0 && height > 0){
        rect = Object.assign(new fabric.Rect({
            left: pointer.x,
            top: rectPoints[1],
            originX:'left',
            originY:'top',
            width: Math.abs(width),
            height: height,
            angle: 0,
            fill: currentBaseInfo.color+'20',
            stroke: currentBaseInfo.color,
            strokeWidth: 2,
            strokeUniform: true,
            transparentCorners: false,
            selectable: false,
            
        }), {index:currentId})
    }else if(width > 0 && height < 0){
        rect = Object.assign(new fabric.Rect({
            left: rectPoints[0],
            top: pointer.y,
            originX:'left',
            originY:'top',
            width: width,
            height: Math.abs(height),
            angle: 0,
            fill: currentBaseInfo.color+'20',
            stroke: currentBaseInfo.color,
            strokeWidth: 2,
            strokeUniform: true,
            transparentCorners: false,
            selectable: false,
            
        }), {index:currentId})
    }else {
        rect = Object.assign(new fabric.Rect({
            left: pointer.x,
            top: pointer.y,
            originX:'left',
            originY:'top',
            width: Math.abs(width),
            height: Math.abs(height),
            angle: 0,
            fill: currentBaseInfo.color+'20',
            stroke: currentBaseInfo.color,
            strokeWidth: 2,
            strokeUniform: true,
            transparentCorners: false,
            selectable: false,
            
        }), {index:currentId})
    }
    
    
    let labelStoreObj:storeObj = {index:currentId, baseInfo:currentBaseInfo, shapeType:201, fabricObj: rect}
    fabricCanvas.add(rect)
    fabricCanvas.renderAll();
    return labelStoreObj
}

//绘制圆
const drawCircle = (points:number[]) => {
    let currentId = generateId()
    let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]
    fabricCanvas.remove(circle)
    // 创建一个初始的圆形对象并添加到画布中
    circle = Object.assign(new fabric.Circle({
        left: (points[2] + points[0]) / 2,
        top: (points[3] + points[1]) / 2,
        radius: Math.min(Math.abs(points[2] - points[0]), Math.abs(points[3] - points[1])) / 2,
        fill: currentBaseInfo.color+'20',
        stroke: currentBaseInfo.color,
        strokeWidth: 2,
        strokeUniform: true,
        originX: 'center',
        originY: 'center',
        selectable: false
    }), {index:currentId})

    const radius = circle.radius

    let labelStoreObj:storeObj = {index:currentId, baseInfo:currentBaseInfo, shapeType:202, fabricObj: circle}
    if(radius > 0){
        fabricCanvas.add(circle)
        return labelStoreObj
    }else{
        labelStoreObj.fabricObj = new fabric.Object
        return labelStoreObj
    }
}


//绘制多边形
const drawPolygon = (points:{x:number, y:number}[]) => {
    let currentId = generateId()
    let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]
    polygon = Object.assign(new fabric.Polygon(points,{
        fill:currentBaseInfo.color+'80',
        selectable: false,
        strokeWidth: 2,
        stroke: currentBaseInfo.color+'80',
    }), {index:currentId})
    let labelStoreObj:storeObj = {index:currentId, baseInfo:currentBaseInfo, shapeType:203, fabricObj: polygon}
    fabricCanvas.add(polygon)
    return labelStoreObj
}

//限定标注点边框位置
const limitPoint = (point:{x:number, y:number}) => {
    const bounds = getImageBounds()
    return {
        x: Math.max(bounds.left, Math.min(point.x, bounds.right)),
        y: Math.max(bounds.top, Math.min(point.y, bounds.bottom)),
    }
} 


// 限制对象不超出背景图片
function limitObjectToBackground(obj:any) {

    if (!imageObj) return;
    const backgroundBounds = getImageBounds()
    obj.setCoords()
    let objBounds = obj.getBoundingRect(true)

    if (objBounds.width > backgroundBounds.width && objBounds.width > 0) {
        obj.scaleX *= backgroundBounds.width / objBounds.width
        obj.setCoords()
        objBounds = obj.getBoundingRect(true)
    }
    if (objBounds.height > backgroundBounds.height && objBounds.height > 0) {
        obj.scaleY *= backgroundBounds.height / objBounds.height
        obj.setCoords()
        objBounds = obj.getBoundingRect(true)
    }

    let deltaX = 0
    let deltaY = 0
    if (objBounds.left < backgroundBounds.left) deltaX = backgroundBounds.left - objBounds.left
    if (objBounds.left + objBounds.width > backgroundBounds.right) {
        deltaX = backgroundBounds.right - (objBounds.left + objBounds.width)
    }
    if (objBounds.top < backgroundBounds.top) deltaY = backgroundBounds.top - objBounds.top
    if (objBounds.top + objBounds.height > backgroundBounds.bottom) {
        deltaY = backgroundBounds.bottom - (objBounds.top + objBounds.height)
    }
    obj.set({ left: (obj.left || 0) + deltaX, top: (obj.top || 0) + deltaY })
    obj.setCoords()

}


onMounted(async () => {
    generateColors()
    let labelStoreObj:storeObj
    aside.enableEditingModel()
    fabricCanvas = new fabric.Canvas(canvas.value, {
        selection : false,
    }
    );
    
    
    fabricCanvas.setDimensions({width:canvasParent.value.clientWidth, height:canvasParent.value.clientHeight});
    fabricCanvas.on('mouse:down', (o:any) => {

        labelStoreObj = {
            index: '',
            baseInfo:{
                    cname:'',
                    color:'',
                    ename:'',
                    index:0
            },
            shapeType:0,
            fabricObj :new fabric.Object(),
        }
        //200:绘制直线 201：绘制矩形 202：绘制圆 203：绘制多边形
        if(currentWorkModel.value === 200){
            let pointer = fabricCanvas.getPointer(o.e)
            pointer = limitPoint(pointer)
            linePoints[0] = pointer.x
            linePoints[1] = pointer.y
            isDrawing = true
        }

        if(currentWorkModel.value === 201){
            let pointer = fabricCanvas.getPointer(o.e)
            isDrawing = true
            pointer = limitPoint(pointer)
            
            rectPoints[0] = pointer.x
            rectPoints[1] = pointer.y

            drawRect(rectPoints)

        }

        if(currentWorkModel.value === 202){
            let pointer = fabricCanvas.getPointer(o.e)
            isDrawing = true
            pointer = limitPoint(pointer)
            circlePoints[0] = pointer.x
            circlePoints[1] = pointer.y
        }

        if(currentWorkModel.value === 203){
            
        }

        if(currentWorkModel.value === 103){
            let evt = o.e
            isDragging = true
            if (evt.altKey === true) {
                canvasLastPosX = evt.clientX
                canvasLastPosY = evt.clientY
            }
        }
    });

    


    fabricCanvas.on('mouse:move', (o:any) => {
        if(currentWorkModel.value === 200){
            if(!isDrawing) return;
            fabricCanvas.isDrawingMode = false
            let pointer = fabricCanvas.getPointer(o.e)
            pointer = limitPoint(pointer)
            linePoints[2] = pointer.x
            linePoints[3] = pointer.y
           
            labelStoreObj = drawLine(linePoints)

        }
        if(currentWorkModel.value === 201){
            
            if(!isDrawing) return;
            let pointer = fabricCanvas.getPointer(o.e);
            pointer = limitPoint(pointer)
            
            labelStoreObj = drawRect(pointer)
        }

        if(currentWorkModel.value === 202){
            if(!isDrawing) return;
            let pointer = fabricCanvas.getPointer(o.e)
            pointer = limitPoint(pointer)
            circlePoints[2] = pointer.x
            circlePoints[3] = pointer.y
            
            labelStoreObj = drawCircle(circlePoints)
        }

        if(currentWorkModel.value === 203){
            fabricCanvas.getObjects().find((o:any) => {
                if(o.uniqueId === 'polygonTmp'){
                    fabricCanvas.remove(o)
                }
            })
            polygonPoints.value.pop()
            polygonTmp.value = new fabric.Polygon([])
            let point = limitPoint(fabricCanvas.getPointer(o.e))
            let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]
            polygonPoints.value.push({x:point.x, y:point.y})
            if(polygonPoints.value.length > 2){
                let polygonT = Object.assign(new fabric.Polygon(polygonPoints.value, {
                    fill:currentBaseInfo.color+'80',
                    selectable: false,
                    strokeWidth: 5,
                    stroke: currentBaseInfo.color+'80',
                }),{uniqueId:'polygonTmp'})
                fabricCanvas.add(polygonT)
                polygonTmp.value = polygonT
            }
            
        }
        if(currentWorkModel.value === 103){
            if(!isDragging)return;
            let evt = o.e
            if (evt.altKey === true) {
                const deltaX = evt.clientX - canvasLastPosX;
                const deltaY = evt.clientY - canvasLastPosY;
                const currentTransform = fabricCanvas.viewportTransform
                currentTransform[4] += deltaX
                currentTransform[5] += deltaY
                fabricCanvas.requestRenderAll()
                canvasLastPosX = evt.clientX;
                canvasLastPosY = evt.clientY;
            }
            
            
        }
    });

    fabricCanvas.on('mouse:up', (o:any) => {

        switch(currentWorkModel.value){
            case 200:
                if(Object.keys(labelStoreObj.fabricObj).length !== 0){
                    labelResults.value.push(labelStoreObj)
                    save()
                }
                isDrawing = false
                line = null
                break
            case 201:
                if(Object.keys(labelStoreObj.fabricObj).length !== 0){
                    labelResults.value.push(labelStoreObj)
                    save()
                }
                isDrawing = false
                rect = null
                
                break
            case 202:
                if(Object.keys(labelStoreObj.fabricObj).length !== 0){
                    labelResults.value.push(labelStoreObj)
                    save()
                }
                isDrawing = false
                circle = null
                
                break
            case 203:
               
                for(let i = 0; i < polygonLines.value.length; i++){
                    let foundLine = fabricCanvas.getObjects().find((obj:any) => obj.uniqueId === 'polygonLineTmp-' + i)
                    fabricCanvas.remove(foundLine)
                }
                polygonLines.value = []
                
                isDrawing = false
                polygon = null
                let pointer = fabricCanvas.getPointer(o.e);

                let point = limitPoint({ x: pointer.x, y: pointer.y })
                polygonPoints.value.push(point)
                // let polygonPoint = new fabric.Circle({
                //     left: point.x,
                //     top: point.y,
                //     radius: 1,
                //     fill: 'red',
                //     selectable: false
                // })
                // fabricCanvas.add(polygonPoint)
                if(polygonPoints.value.length > 1){
                    for(let i = 0; i < polygonPoints.value.length - 1; i++){
                        
                        let linePoints = [polygonPoints.value[i].x, polygonPoints.value[i].y, polygonPoints.value[i + 1].x, polygonPoints.value[i + 1].y]
                        
                        let currentBaseInfo = labelList.value[currentLabelTypeIndex.value]
                        let polygonLine = Object.assign(new fabric.Line(linePoints, {
                            fill:currentBaseInfo.color+'80',
                            selectable: false,
                            strokeWidth: 2,
                            stroke: currentBaseInfo.color+'80',
                            
                        }), {uniqueId: 'polygonLineTmp-' + i})
                        polygonLines.value.push(polygonLine)
                        fabricCanvas.add(polygonLine)
                    }
                }

                fabricCanvas.renderAll()
                break
        }
       
 

        if(currentWorkModel.value === 103){
            if(fabricCanvas.getActiveObject()){
                save()
            }else{
                fabricCanvas.setViewportTransform(fabricCanvas.viewportTransform)
            }
            isDragging = false
        }
    
    });

    fabricCanvas.on('object:moving', (e:any) => {
        limitObjectToBackground(e.target)
    })

    fabricCanvas.on('object:scaling', (e:any) => {
        limitObjectToBackground(e.target)
    })

    fabricCanvas.on('object:modified', (e:any) => {
        limitObjectToBackground(e.target)
        fabricCanvas.renderAll()
        save()
    })

    fabricCanvas.on('mouse:wheel', (opt:any) =>{
    const delta = opt.e.deltaY // 滚轮，向上滚一下是 -100，向下滚一下是 100
    let zoom = fabricCanvas.getZoom() // 获取画布当前缩放值
    zoom *= 0.999 ** delta
    if(zoom < 1){
        zoom = 1
    }
    if(zoom > 8){
        zoom = 8
    }
    fabricCanvas.zoomToPoint({
            x: opt.e.offsetX,
            y: opt.e.offsetY
        }, zoom)
        opt.e.preventDefault()
        opt.e.stopPropagation()
        document.body.style.overflow = 'hidden'
    })

    fabricCanvas.on('mouse:over', (opt:any) =>{

        document.body.style.overflow = 'hidden'
    })

    fabricCanvas.on('mouse:out', (opt:any) =>{

        document.body.style.overflow = 'auto'
    })

    // 禁用原生右键菜单 绘制多边形
    fabricCanvas.upperCanvasEl.addEventListener('contextmenu', function(e: Event) {
        e.preventDefault(); // 禁止默认的右键菜单
        
        if(currentDrawType.value == 203){
            let point = fabricCanvas.getPointer(e)
            point = limitPoint(point)
            polygonPoints.value.push(point)
            // let polygonPoint = new fabric.Circle({
            //     left: point.x,
            //     top: point.y,
            //     radius: 1,
            //     fill: 'red',
            //     selectable: false
            // })
            // fabricCanvas.add(polygonPoint)
            labelStoreObj = drawPolygon(polygonPoints.value)
            labelResults.value.push(labelStoreObj)
            save()
            for(let i = 0; i < polygonLines.value.length; i++){
                let foundLine = fabricCanvas.getObjects().find((obj:any) => obj.uniqueId === 'polygonLineTmp-' + i)
                fabricCanvas.remove(foundLine)
            }
            
            fabricCanvas.getObjects().find((o:any) => {
                if(o.uniqueId === 'polygonTmp'){
                    fabricCanvas.remove(o)
                }
            })
            polygonLines.value = []
            polygonPoints.value = []
        }
       
    });
    
    
    window.addEventListener('resize', handleResize);
    document.addEventListener('keydown', handleCanvasKeydown)
    await loadTaskImages()
    await loadLabeledStates()
    const routeFileIndex = currentFiles.value.findIndex((file) => file.id === routeFileId.value)
    currentFileIndex.value = routeFileIndex >= 0 ? routeFileIndex : 0
    loadCurrentFile()
})




onUnmounted(() => {
    aside.disableEditingModel()
    window.removeEventListener('resize', handleResize)
    document.removeEventListener('keydown', handleCanvasKeydown)
    fabricCanvas?.dispose()
})

const handleEdit = (objIn:storeObj) => {
    changeModel(103)
    fabricCanvas.getObjects().forEach((o:any) => {
        if(o.index === objIn.index){
            fabricCanvas.setActiveObject(o)
        }
    })
    fabricCanvas.renderAll()
}

const handleDelete = (objIn:storeObj) => {
    fabricCanvas.getObjects().forEach((o:any) => {
        if(o.index === objIn.index){
            fabricCanvas.remove(o)           
        }
    })
    let deepCloneTmp = cloneDeep(labelResults.value)
    deepCloneTmp = deepCloneTmp.filter(o => o.index !== objIn.index)
    labelResults.value = deepCloneTmp
    fabricCanvas.renderAll()

}

const handleHide = (objIn:storeObj) => {
    fabricCanvas.getObjects().forEach((o:any) => {
        if(o.index === objIn.index){
            o.set('visible', !o.visible)           
        }
    })
    fabricCanvas.renderAll()
}

</script>

<style lang="scss" scoped>
.labeling-layout{
    height: 92vh;
    width: 100vw;
    display: flex;
}
.labeling-aside{
    width:6%;
    height:100%; 
    background-color: rgb(0, 21, 41);
}

.create-shape{
    margin-top: 30%;
    height: 40%;
    display: flex;
    align-items: center;
    flex-direction: column;
    
    span{
        background-color: rgb(172, 184, 232);
        width: 100%;
        height: 15%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .create-shape-button{
        margin-top: 20%;
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: space-between;
        button{
            background-color: transparent;
            border: none;
            width: 100%;           
            svg{
                width: 100%;
                font-size: 2em;
                fill: white;
            }

            &:hover{
                cursor: pointer;
                svg{
                    width: 100%;
                    font-size: 3em;
                    fill: rgb(39, 86, 236);
                }
            }
            &.active{
                background-color: rgba(37, 99, 235, 0.35);
                box-shadow: inset 3px 0 0 #60a5fa;
            }
        }
    }
}

.tool-box{
    margin-top: 30%;
    height: 40%;
    display: flex;
    align-items: center;
    flex-direction: column;
    
    span{
        background-color: rgb(172, 184, 232);
        width: 100%;
        height: 15%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .tool-box-button{
        margin-top: 20%;
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: space-between;
        button{
            background-color: transparent;
            border: none;
            width: 100%;   
            svg{
                width: 100%;
                font-size: 2em;
                fill: white;
            }
            &:hover{
                cursor: pointer;
                svg{
                    width: 100%;
                    font-size: 3em;
                    fill: rgb(39, 86, 236);
                }
            }
            &.active{
                background-color: rgba(37, 99, 235, 0.35);
                box-shadow: inset 3px 0 0 #60a5fa;
            }
        }
    }
}

.label-main{
    height: 100%;
    padding: 0;
    overflow: scroll;
    width: 70%;
    &::-webkit-scrollbar{
        display: none;
    }
    .switch-img{
        width: 100%;
        height: 8%;
        display: flex;
        align-items: center;
        justify-content: center;
            button{
                border: none;
                background-color: transparent;
                font-size: 2em;
                padding-right: 2.3em;
                padding-left: 2em;
            }
    }
    .label-canvas{
        height: 60%;
        width: 100%;
        canvas {
            border: 1px solid #ccc;
        }
    }
}

.labeling-result-aside{
    display: flex;
    flex-direction: column;
    width: 24%;
    .label-list{
        height: 31%;
        width: 100%;
        .head{
            width: 100%;
            height: 12%;
            background-color: rgb(0, 24, 41);
            color: white;
        }
        .content{
            overflow: auto;
            width: 100%;
            height: 88%;
            background-color: rgb(46, 47, 70);
            color: white;
        }
    }
    .label-result{
        height: 34%;
        width: 100%;
        .head{
            width: 100%;
            height: 12%;
            background-color: rgb(0, 24, 41);
            color: white;
        }
        .content{
            overflow: auto;
            width: 100%;
            height: 88%;
            background-color: rgb(46, 47, 70);
        }
    }
    .file-list{
        height: 35%;
        width: 100%;
        .head{
            width: 100%;
            height: 12%;
            background-color: rgb(0, 24, 41);
            color: white;
        }
        .content{
            width: 100%;
            height: 88%;
            background-color: rgb(46, 47, 70);

            .search-sift{
                margin: 5% 0 0 5%;
                padding: 5%;
                width: 80%;
                border-radius: 0.5em ;
                background-color: rgb(28, 29, 55);
                input{

                    &::placeholder{
                        font-size: 0.7rem;
                    }
                }
            }

            .is-label  {
                margin: 5% 0 0 0;
                padding: 3% 0 0 0;
                :deep(.el-select__wrapper){
                    background-color: rgb(28, 29, 55) !important;
                    box-shadow:0 0 0 0;
                    border-radius: 0.5em;
                    height: 2.5em;
                    
                }
                :deep(.el-select__placeholder){
                    font-size: 0.7rem;
                }
                :deep(.el-select-dropdown__wrap){
                    background-color: rgb(28, 29, 55) !important;
    
                }

                :deep(.el-select-dropdown__item){   
                    &:hover{
                        background-color: aquamarine;
                    }
                }
                :deep(.el-select-dropdown__item.is-selected){   
                    background: aquamarine !important;
                }
                :deep(.el-select__popper.el-popper) {
                    border: rgba(28, 29, 55) !important; // 修改内部下拉框的边框颜色
                }
                :deep(.el-popper__arrow::before){
                    background: rgb(28, 29, 55) !important;
                    border: 1px solid rgb(28, 29, 55) !important;
                }
            }
            .table-data{
               :deep(.el-table__inner-wrapper::before){
                    height: 0;          //消除表格底部白线
               }
            }
            
        }
    }
}



.label-button{
    height: 20%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    .exit-button{
        background-color: rgb(56, 181, 74);
        border: 0;
        border-radius: 2em;
        width: 15%;
        height: 2em;
        margin-right: 3%;
        color: white;
    }
    .save-button{
        background-color: rgb(56, 181, 74);
        border: 0;
        border-radius: 2em;
        width: 15%;
        height: 2em;
        margin-left: 3%;
        color: white;
    }
}


</style>



<template>
    <div>
        <el-space :fill=true direction="vertical" wrap style="width: 100%;height: 100%;overflow: hidden;" >
            <!-- 导航栏开始 -->
            <div class="bread-nav">
                <el-breadcrumb :separator-icon="ArrowRight">
                    <el-breadcrumb-item :to="{ path: '/taskCenter' }">任务中心</el-breadcrumb-item>
                    <el-breadcrumb-item>训练模型</el-breadcrumb-item>
                </el-breadcrumb>
            </div>
            <!-- 导航栏结束 -->
            <el-steps
                style="align-items: center; justify-content: center; width: 100%;margin: 5vh 0 5vh 0;"
                :space="400"
                :active="activeStep"
                finish-status="success"
                align-center
            >
                <el-step title="训练配置" />
                <el-step title="模型查看" />
            </el-steps>
            <div v-if="trainResult === 1" >
                <div style="display: flex;flex-direction: row;">
                    <el-skeleton style="width: 40%;height: 40vh;margin: 0 0 0 5vw;">
                        <template #template>
                            <el-skeleton-item variant="image" style="margin:2rem 0 0 0;width: 100%; height: 100%" />
                        </template>
                    </el-skeleton>
                    <el-skeleton style="width: 40%;height: 40vh;margin: 0 0 0 5vw;">
                        <template #template>
                            <el-skeleton-item variant="image" style="margin:2rem 0 0 0;width: 100%; height: 100%" />
                        </template>
                    </el-skeleton>
                </div>
                
                <!-- 底部按钮 -->
                <div style="display: flex;justify-content: center;  margin: 10vh 0 0 0;">
                    <el-button class="button-content"  @click="handleExit()">
                        退出
                    </el-button>
                    <el-button class="button-content" @click="handleLastStep()">
                        上一步
                    </el-button>
                </div>
            </div>
            <div v-else class="content-train">
                <svg-icon v-if="trainResult === 0" iconName="icon-loading" class="loading"></svg-icon>
                <svg-icon v-else-if="trainResult === 2" iconName="icon-cuowu" style="color: red;width: 10vw;height: 10vh;"></svg-icon>
                <div class="progress">
                    <el-progress
                        v-if="trainResult === 0"
                        :text-inside="true"
                        :stroke-width="20"
                        :percentage="50"
                        status="success"
                    />
                    <el-progress
                        v-else-if="trainResult === 2"
                        :text-inside="true"
                        :stroke-width="20"
                        :percentage="50"
                        status="exception"
                    />
                </div>
                <div style="display: flex;justify-content: center;font-weight: bold;">
                    <p v-if="trainResult === 0 ">模型正在训练中，请稍等</p>
                    <p v-if="trainResult === 2">训练失败</p>
                </div>

                <!-- 底部按钮 -->
                <div style="display: flex;justify-content: center;  margin: 25vh 0 0 0;">
                    <el-button class="button-content"  @click="handleExit()">
                        退出
                    </el-button>
                    <el-button class="button-content" @click="handleLastStep()">
                        上一步
                    </el-button>
                </div>
            </div>
            

            
        </el-space>
    </div>
</template>
<script lang="ts" setup>
import { ArrowRight } from '@element-plus/icons-vue'
import {onMounted, ref} from 'vue'


const trainResult = ref()
trainResult.value = history.state.trainResult

const activeStep = ref(0)

const handleExit = () => {

}

const handleLastStep = () => {

}

onMounted(() =>{
    if(trainResult.value === 0 || trainResult.value === 2){
        activeStep.value = 1
    }else if(trainResult.value === 1){
        activeStep.value = 2
    }
})

</script>

<style lang="scss" scoped>
.bread-nav{
    margin: 0.5% 0 0.5% 0.5%;
    
}

.progress{
    margin: 5vh 0 0 0;
    width: 100%;
    display: flex;
    justify-content: center;
    :deep(.el-progress){
        width: 50vw;
    }

    :deep(.el-progress-bar__innerText){
        vertical-align:middle;
        font-size: 1rem;
        color: black;
    }
}




.content-train{
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    .loading{
        animation: rotation 7s infinite linear;
        width: 10vw;
        height: 10vh;
        
    }
    @keyframes rotation {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}
}





.button-content{
    margin: 0 2vw 0 2vw;
    background: rgb(56, 181, 74) ;
    color:white;
    width: 12em;
    border-radius: 2em;
}

</style>
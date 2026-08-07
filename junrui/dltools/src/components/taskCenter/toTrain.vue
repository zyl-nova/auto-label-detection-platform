<template>
  <div class="page">
    <el-page-header content="创建训练任务" @back="router.push('/taskCenter')" />
    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" class="form">
      <el-divider content-position="left">基础信息</el-divider>
      <el-form-item label="任务名称" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="样本集" prop="sampleId">
        <el-select v-model="form.sampleId" placeholder="选择样本集" @change="syncProjectBySample">
          <el-option v-for="sample in business.samples" :key="sample.id" :label="`${sample.name}（${sample.projectName}）`" :value="sample.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="任务描述">
        <el-input v-model="form.description" type="textarea" :rows="3" />
      </el-form-item>

      <el-divider content-position="left">训练参数</el-divider>
      <el-form-item label="预训练模型" prop="modelId">
        <el-select v-model="form.modelId" placeholder="选择模型">
          <el-option v-for="model in business.models" :key="model.id" :label="`${model.name}（${model.taskType}/${model.targetType}）`" :value="model.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="学习率" prop="learningRate">
        <el-select v-model="form.learningRate">
          <el-option :value="0.001" label="0.001" />
          <el-option :value="0.005" label="0.005" />
          <el-option :value="0.01" label="0.01" />
        </el-select>
      </el-form-item>
      <el-form-item label="Epoch" prop="epoch">
        <el-input-number v-model="form.epoch" :min="1" :step="10" />
      </el-form-item>
      <el-form-item label="批量大小" prop="batchSize">
        <el-input-number v-model="form.batchSize" :min="1" :step="4" />
      </el-form-item>
      <el-form-item>
        <el-button @click="router.push('/taskCenter')">取消</el-button>
        <el-button type="primary" :loading="submitting" :disabled="submitting" @click="submitForm(formRef)">开始训练</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { useRoute, useRouter } from 'vue-router'
import allStore from '@/stores'
import { startTraining } from '@/api/training'

const router = useRouter()
const route = useRoute()
const { business } = allStore()
const formRef = ref<FormInstance>()
const submitting = ref(false)

const form = reactive({
  name: '',
  sampleId: undefined as number | undefined,
  modelId: undefined as number | undefined,
  learningRate: 0.01,
  epoch: 100,
  batchSize: 16,
  description: '',
})

const rules = reactive<FormRules>({
  name: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  sampleId: [{ required: true, message: '请选择样本集', trigger: 'change' }],
  modelId: [{ required: true, message: '请选择预训练模型', trigger: 'change' }],
})

const syncProjectBySample = () => undefined

const submitForm = async (formEl?: FormInstance) => {
  if (!formEl) return
  await formEl.validate(async (valid) => {
    if (!valid || !form.sampleId || !form.modelId) return
    const sample = business.samples.find((item) => item.id === form.sampleId)
    const model = business.models.find((item) => item.id === form.modelId)
    if (!sample || !model) return
    if (!sample.sourceTaskId) {
      ElMessage.warning('该样本没有关联已标注任务，无法生成训练数据集')
      return
    }
    if (submitting.value) return
    submitting.value = true
    try {
      const job = await startTraining({
        labelTaskId: sample.sourceTaskId,
        taskName: form.name,
        epochs: form.epoch,
        batchSize: form.batchSize,
        learningRate: form.learningRate,
      })
      const task = business.addTrainTask({
        name: form.name,
        projectId: sample.projectId,
        projectName: sample.projectName,
        sampleId: sample.id,
        sampleName: sample.name,
        modelId: model.id,
        modelName: model.name,
        learningRate: form.learningRate,
        epoch: form.epoch,
        batchSize: form.batchSize,
        description: form.description,
        jobId: job.jobId,
        message: `已准备 ${job.sampleCount} 张样本`,
      })
      ElMessage.success('训练任务已启动')
      await router.replace({ name: 'trainSituation', query: { taskId: String(task.id) } })
    } catch (error:any) {
      ElMessage.error(error?.message || '启动训练失败')
    } finally {
      submitting.value = false
    }
  })
}

onMounted(() => {
  const sampleId = Number(route.query.sampleId)
  if (sampleId) form.sampleId = sampleId
})
</script>

<style scoped>
.page {
  padding: 22px;
}

.form {
  margin-top: 22px;
  max-width: 780px;
}
</style>
